/* NAT/VPN server */
resource "aws_instance" "nat" {
  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.public.id
  security_groups   = [aws_security_group.default.id, aws_security_group.nat.id]
  key_name          = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = "nat"
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -A POSTROUTING -j MASQUERADE",
      "echo 1 | sudo tee /proc/sys/net/ipv4/conf/all/forwarding",
      "sudo apt-get update",
      "sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'",
      "sudo apt-get update",
      "sudo apt-get -y install docker-ce",
      "sudo usermod -aG docker ubuntu",
      "sudo apt-get -y install vim",
      "sudo mkdir -p /etc/openvpn",
      "sudo docker run --name ovpn-data -v /etc/openvpn busybox",
      "sudo docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -p ${var.vpc_cidr} -u udp://${aws_instance.nat.public_ip}",
    ]
  }
}
