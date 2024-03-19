

#******************creating new VPC network****************************************************************

resource "google_compute_network" "vpc_network1" {
  project                 = "terraform-learning-412915"
  name                    = var.vpc_name
  auto_create_subnetworks = false

}

#******************creating new sub network****************************************************************

resource "google_compute_subnetwork" "subnet1" {
  name                     = var.subnet_name
  ip_cidr_range            = "10.3.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_network1.id
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc_network1]
}

#******************creating new vm instance****************************************************************

resource "google_compute_instance" "vm-from-tf" {
  name         = "vm-from-tf"
  zone         = "us-central1-a"
  machine_type = "n1-standard-2"

  allow_stopping_for_update = true

  network_interface {
    network    = google_compute_network.vpc_network1.name
    subnetwork = google_compute_subnetwork.subnet1.name
    access_config {
      nat_ip = google_compute_address.static.address #static external ip address
    }
  }

  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20210916"
      size  = 20

    }
    auto_delete = true
  }


  labels = {
    "env" = "tfleaning"
  }


  scheduling {
    preemptible       = false
    automatic_restart = true
  }

  service_account {
    email  = "terraform-gcp@terraform-learning-412915.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [
      attached_disk
    ]
  }


  tags = ["http-server", "https-server", "ssh"]

  depends_on = [google_compute_subnetwork.subnet1]

}

/*
#******************creating additional disk***********************

resource "google_compute_disk" "disk-1" {
  name       = "disk-1"
  size       = 15
  zone       = "us-central1-a"
  type       = "pd-ssd"
  depends_on = [google_compute_instance.vm-from-tf]
}

#******************attaching additional disks to vm instance***********************

resource "google_compute_attached_disk" "adisk" {
  disk     = google_compute_disk.disk-1.id
  instance = google_compute_instance.vm-from-tf.id

  depends_on = [google_compute_disk.disk-1]
}

*/

#******************creating new firewall rules and tag them in vm instance***********************************

resource "google_compute_firewall" "allow_http" {
  name    = "customrules"
  network = google_compute_network.vpc_network1.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22", "1000-2000"]
  }
  target_tags = ["http-server", "https-server", "ssh"]
  priority    = 1000

}

#******************creating Static external ip address for VM *******************************************
resource "google_compute_address" "static" {
  name = "ipv4-address"
  region = "us-central1"
}


/*
#*****************creating bucket for backend state file in gcs******************************

resource "google_storage_bucket" "GCS1" {

  name          = var.bucket_name
  storage_class = "STANDARD"
  location      = "US-CENTRAL1"

  versioning {

    enabled = true
  }
  labels = {
    "env" = "terraform_env"
    "dep" = "compliance"
  }
  uniform_bucket_level_access = true

   lifecycle_rule {
    condition {
      age = 2
    }
    action {
      type = "Delete"
    }
  } 

  retention_policy {
    is_locked = false
    retention_period = 864000
  }

}
*/
/*
resource "google_storage_bucket_object" "picture" {
  name = "vodafone_logo"
  bucket = google_storage_bucket.GCS1.name
  source = "vodafone.jpg"
}*/

