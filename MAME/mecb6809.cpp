// license:BSD-3-Clause
// copyright-holders:Frank Palazzolo

// MAME driver for DigicoolThing's 6809 Computer

#include "emu.h"

#include "cpu/m6809/m6809.h"
#include "machine/6850acia.h"

#include "machine/clock.h"
#include "bus/rs232/rs232.h"


namespace {

class mecb6809_state : public driver_device
{
public:
	mecb6809_state(const machine_config &mconfig, device_type type, const char *tag)
		: driver_device(mconfig, type, tag)
		, m_maincpu(*this, "maincpu")
		, m_acia(*this, "acia")
	{ }

	void mecb6809(machine_config &config);

private:
	void mecb6809_mem(address_map &map);

	required_device<cpu_device> m_maincpu;
	required_device<acia6850_device> m_acia;
};

void mecb6809_state::mecb6809_mem(address_map &map)
{
	map(0x0000, 0xbfff).ram();
	map(0xc008, 0xc00f).rw("acia", FUNC(acia6850_device::read), FUNC(acia6850_device::write));
	map(0xc100, 0xffff).rom();
}

// This is here only to configure our terminal for interactive use
static DEVICE_INPUT_DEFAULTS_START( terminal )
	DEVICE_INPUT_DEFAULTS( "RS232_RXBAUD", 0xff, RS232_BAUD_115200 )
	DEVICE_INPUT_DEFAULTS( "RS232_TXBAUD", 0xff, RS232_BAUD_115200 )
	DEVICE_INPUT_DEFAULTS( "RS232_DATABITS", 0xff, RS232_DATABITS_8 )
	DEVICE_INPUT_DEFAULTS( "RS232_PARITY", 0xff, RS232_PARITY_NONE )
	DEVICE_INPUT_DEFAULTS( "RS232_STOPBITS", 0xff, RS232_STOPBITS_1 )
DEVICE_INPUT_DEFAULTS_END

void mecb6809_state::mecb6809(machine_config &config)
{
	/* basic machine hardware */
	MC6809(config, m_maincpu, XTAL(4'000'000));
	m_maincpu->set_addrmap(AS_PROGRAM, &mecb6809_state::mecb6809_mem);

	// Configure UART (via m_acia)
	ACIA6850(config, m_acia, 0);
	m_acia->txd_handler().set("rs232", FUNC(rs232_port_device::write_txd));
	// should this be reverse polarity?
	m_acia->irq_handler().set("rs232", FUNC(rs232_port_device::write_rts));

	clock_device &acia_clock(CLOCK(config, "acia_clock", 7'372'800/4)); // E Clock from M6809
	acia_clock.signal_handler().set("acia", FUNC(acia6850_device::write_txc));
	acia_clock.signal_handler().append("acia", FUNC(acia6850_device::write_rxc));

	// Configure a "default terminal" to connect to the 6850, so we have a console
	rs232_port_device &rs232(RS232_PORT(config, "rs232", default_rs232_devices, "terminal"));
	rs232.rxd_handler().set(m_acia, FUNC(acia6850_device::write_rxd));
	rs232.set_option_device_input_defaults("terminal", DEVICE_INPUT_DEFAULTS_NAME(terminal)); // must be below the DEVICE_INPUT_DEFAULTS_START block
}

ROM_START(mecb6809)
	ROM_REGION(0x10000, "maincpu",0)
	ROM_LOAD("mecb6809.bin",   0xC100, 0x3F00, CRC(fbbd6038) SHA1(da9092a9e0c78605cfdd7c424c455422b6aaf052))
ROM_END

} // anonymous namespace


//    YEAR  NAME         PARENT    COMPAT  MACHINE   INPUT    CLASS         INIT           COMPANY           FULLNAME                FLAGS
COMP( 2024, mecb6809,      0,        0,      mecb6809,   0,       mecb6809_state, empty_init,    "DigicoolThings",   "MECB 6809 Combo",  MACHINE_NO_SOUND_HW )
