output "master_ip"  { value = local.nodes["k8s-master"].ip }
output "worker_ips" { value = [local.nodes["k8s-worker1"].ip, local.nodes["k8s-worker2"].ip] }
output "access_url" { value = "http://192.168.192.11" }
