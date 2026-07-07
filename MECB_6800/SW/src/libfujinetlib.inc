FUJINET_LIB_BASE                          equ   $c000
;
fujinet_reset                             equ   FUJINET_LIB_BASE+$00
fujinet_dcb_exec                          equ   FUJINET_LIB_BASE+$03
fn_perror                                 equ   FUJINET_LIB_BASE+$06
fujinet_mount_all                         equ   FUJINET_LIB_BASE+$09
fujinet_mount_host                        equ   FUJINET_LIB_BASE+$0C
fujinet_read_host_slots                   equ   FUJINET_LIB_BASE+$0F
fujinet_read_device_slots                 equ   FUJINET_LIB_BASE+$12
fujinet_random_number                     equ   FUJINET_LIB_BASE+$15
fujinet_get_time                          equ   FUJINET_LIB_BASE+$18
fujinet_open_directory                    equ   FUJINET_LIB_BASE+$1B
fujinet_read_dir_entry                    equ   FUJINET_LIB_BASE+$1E
fujinet_close_directory                   equ   FUJINET_LIB_BASE+$21
fujinet_set_directory_position            equ   FUJINET_LIB_BASE+$24
fujinet_get_directory_position            equ   FUJINET_LIB_BASE+$27
fujinet_write_appkey                      equ   FUJINET_LIB_BASE+$2A
fujinet_read_appkey                       equ   FUJINET_LIB_BASE+$2D
fujinet_open_appkey                       equ   FUJINET_LIB_BASE+$30
fujinet_close_appkey                      equ   FUJINET_LIB_BASE+$33

fujinet_device_create_new                 equ   FUJINET_LIB_BASE+$36
fujinet_device_disable_device             equ   FUJINET_LIB_BASE+$39
fujinet_device_enable_device              equ   FUJINET_LIB_BASE+$3C
fujinet_device_get_adapter_config         equ   FUJINET_LIB_BASE+$3F
fujinet_device_get_device_enabled_status  equ   FUJINET_LIB_BASE+$42
fujinet_device_get_device_filename        equ   FUJINET_LIB_BASE+$45
fujinet_write_device_slots                equ   FUJINET_LIB_BASE+$48
fujinet_write_host_slots                  equ   FUJINET_LIB_BASE+$4B
fujinet_device_set_boot_config            equ   FUJINET_LIB_BASE+$4E
fujinet_device_set_device_filename        equ   FUJINET_LIB_BASE+$51
fujinet_logical_device_type               equ   FUJINET_LIB_BASE+$54
fujinet_logical_device_unit               equ   FUJINET_LIB_BASE+$57
fujinet_logical_device_url                equ   FUJINET_LIB_BASE+$5A
fujinet_mount_image                       equ   FUJINET_LIB_BASE+$5D
fujinet_disk_read                         equ   FUJINET_LIB_BASE+$60
fujinet_unmount_image                     equ   FUJINET_LIB_BASE+$63
fujinet_disk_get_sector_size              equ   FUJINET_LIB_BASE+$66
fujinet_disk_write                        equ   FUJINET_LIB_BASE+$69

fujinet_file_open                         equ   FUJINET_LIB_BASE+$6C
fujinet_file_read                         equ   FUJINET_LIB_BASE+$6F
fujinet_file_status                       equ   FUJINET_LIB_BASE+$72
fujinet_file_write                        equ   FUJINET_LIB_BASE+$75
fujinet_file_close                        equ   FUJINET_LIB_BASE+$78

fujinet_network_open                      equ   FUJINET_LIB_BASE+$7B
fujinet_network_read                      equ   FUJINET_LIB_BASE+$7E
fujinet_network_status                    equ   FUJINET_LIB_BASE+$81
fujinet_network_write                     equ   FUJINET_LIB_BASE+$84
fujinet_network_close                     equ   FUJINET_LIB_BASE+$87
fujinet_network_channel_mode              equ   FUJINET_LIB_BASE+$8A
fujinet_network_json_parse                equ   FUJINET_LIB_BASE+$8D
fujinet_network_json_query                equ   FUJINET_LIB_BASE+$90
fujinet_network_login                     equ   FUJINET_LIB_BASE+$93

fujinet_modem_read                        equ   FUJINET_LIB_BASE+$96
fujinet_modem_status                      equ   FUJINET_LIB_BASE+$99
fujinet_modem_stream                      equ   FUJINET_LIB_BASE+$9C
fujinet_modem_write                       equ   FUJINET_LIB_BASE+$9F

fujinet_printer_stream                    equ   FUJINET_LIB_BASE+$A2
fujinet_printer_write                     equ   FUJINET_LIB_BASE+$A5

fujinet_scan_for_networks                 equ   FUJINET_LIB_BASE+$A8
fujinet_get_scan_result                   equ   FUJINET_LIB_BASE+$AB
fujinet_get_ssid                          equ   FUJINET_LIB_BASE+$AE
fujinet_get_wifi_status                   equ   FUJINET_LIB_BASE+$B1
fujinet_set_ssid                          equ   FUJINET_LIB_BASE+$B4
fujinet_get_wifi_enabled                  equ   FUJINET_LIB_BASE+$B7

fujinet_new_disk                          equ   FUJINET_LIB_BASE+$BA
fujinet_set_host_prefix                   equ   FUJINET_LIB_BASE+$BD
fujinet_get_host_prefix                   equ   FUJINET_LIB_BASE+$C0
fujinet_copy_file                         equ   FUJINET_LIB_BASE+$C3
fujinet_set_boot_mode                     equ   FUJINET_LIB_BASE+$C6
fujinet_status                            equ   FUJINET_LIB_BASE+$C9
fujinet_get_adapterconfig_extended        equ   FUJINET_LIB_BASE+$CC
fujinet_generate_guid                     equ   FUJINET_LIB_BASE+$CF
fujinet_set_status                        equ   FUJINET_LIB_BASE+$D2
fujinet_unmount_host                      equ   FUJINET_LIB_BASE+$D5
