output "priv_ip_address" {
  description = "The IP Address assigned to the main VM NIC"
  value       = azurerm_network_interface.ani.private_ip_address
}

output "nic_id" {
  description = "the IP Address of the VM Network Interface"
  value       = azurerm_network_interface.ani.id
}

output "vm_id" {
  value = azurerm_virtual_machine.awvm.id
}