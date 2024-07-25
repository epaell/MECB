// license:BSD-3-Clause
// copyright-holders:Frank Palazzolo

// MAME driver for DigicoolTing's 6502 Computer

#include "emu.h"

#include "cpu/m6502/m6502.h"
#include "machine/6850acia.h"
#include "machine/6840ptm.h"
#include "machine/clock.h"
#include "bus/rs232/rs232.h"
#include "video/tms9928a.h"

namespace {

class mecb6502_state : public driver_device
{
public:
	mecb6502_state(const machine_config &mconfig, device_type type, const char *tag)
		: driver_device(mconfig, type, tag)
		, m_maincpu(*this, "maincpu")
		, m_acia(*this, "acia")
        , m_ptm(*this, "ptm")
	{ }

	void mecb6502(machine_config &config);

private:
	void mecb6502_mem(address_map &map);

	required_device<cpu_device> m_maincpu;
	required_device<acia6850_device> m_acia;
	required_device<ptm6840_device> m_ptm;
};

void mecb6502_state::mecb6502_mem(address_map &map)
{
	map(0x0000, 0xb7ff).ram();
	map(0xb800, 0xbfff).rom();
	map(0xe000, 0xe007).rw("ptm", FUNC(ptm6840_device::read), FUNC(ptm6840_device::write));
	map(0xe008, 0xe00c).rw("acia", FUNC(acia6850_device::read), FUNC(acia6850_device::write));
	map(0xe080, 0xe081).rw("vdp", FUNC(tms9928a_device::read),FUNC(tms9928a_device::write));
	map(0xe100, 0xffff).rom();
}

// This is here only to configure our terminal for interactive use
static DEVICE_INPUT_DEFAULTS_START( terminal )
	DEVICE_INPUT_DEFAULTS( "RS232_RXBAUD", 0xff, RS232_BAUD_115200 )
	DEVICE_INPUT_DEFAULTS( "RS232_TXBAUD", 0xff, RS232_BAUD_115200 )
	DEVICE_INPUT_DEFAULTS( "RS232_DATABITS", 0xff, RS232_DATABITS_8 )
	DEVICE_INPUT_DEFAULTS( "RS232_PARITY", 0xff, RS232_PARITY_NONE )
	DEVICE_INPUT_DEFAULTS( "RS232_STOPBITS", 0xff, RS232_STOPBITS_1 )
DEVICE_INPUT_DEFAULTS_END

void mecb6502_state::mecb6502(machine_config &config)
{
	/* basic machine hardware */
	M6502(config, m_maincpu, XTAL(4'000'000));
	m_maincpu->set_addrmap(AS_PROGRAM, &mecb6502_state::mecb6502_mem);

	// Configure UART (via m_acia)
	ACIA6850(config, m_acia, 0);
	m_acia->txd_handler().set("rs232", FUNC(rs232_port_device::write_txd));
	// should this be reverse polarity?
	m_acia->irq_handler().set("rs232", FUNC(rs232_port_device::write_rts));

	clock_device &acia_clock(CLOCK(config, "acia_clock", 1'843'200));
	acia_clock.signal_handler().set("acia", FUNC(acia6850_device::write_txc));
	acia_clock.signal_handler().append("acia", FUNC(acia6850_device::write_rxc));

	// Configure a "default terminal" to connect to the 6850, so we have a console
	rs232_port_device &rs232(RS232_PORT(config, "rs232", default_rs232_devices, "terminal"));
	rs232.rxd_handler().set(m_acia, FUNC(acia6850_device::write_rxd));
	rs232.set_option_device_input_defaults("terminal", DEVICE_INPUT_DEFAULTS_NAME(terminal)); // must be below the DEVICE_INPUT_DEFAULTS_START block

	PTM6840(config, m_ptm, 16_MHz_XTAL / 4);
	m_ptm->set_external_clocks(4000000.0/14.0, 4000000.0/14.0, (4000000.0/14.0)/8.0);
	m_ptm->irq_callback().set_inputline("maincpu", M6502_IRQ_LINE);

	// video hardware
	tms9929a_device &vdp(TMS9929A(config, "vdp", XTAL(10'738'635)));
	vdp.set_screen("screen");
	vdp.set_vram_size(0x4000);
	vdp.int_callback().set_inputline("maincpu", m6502_device::IRQ_LINE);
	SCREEN(config, "screen", SCREEN_TYPE_RASTER);
}

ROM_START(mecb6502)
	ROM_REGION(0x10000, "maincpu",0)
	ROM_LOAD("bioscv.rom",   0xb800, 0x0800, CRC(c3c590c6) SHA1(5ac620c529e4965efb5560fe824854a44c983757))
	ROM_LOAD("mecb6502.bin",   0xe100, 0x1f00, CRC(e84486a7) SHA1(f9f1b4c76b8c1d207106412168862dcf677bb7ed))
ROM_END

} // anonymous namespace


//    YEAR  NAME         PARENT    COMPAT  MACHINE   INPUT    CLASS         INIT           COMPANY           FULLNAME                FLAGS
COMP( 2024, mecb6502,      0,        0,      mecb6502,   0,       mecb6502_state, empty_init,    "DigicoolThings",   "MECB 6502 SMON",  MACHINE_NO_SOUND_HW ) // schematics are dated 2009-2013
