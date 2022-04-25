data "google_project" "project" {
}

resource "google_project_service_identity" "gcp-sa-cloud-sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

# [START cloud_sql_instance_iam_conditions]
data "google_iam_policy" "sql_iam_policy" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${google_project_service_identity.gcp-sa-cloud-sql.email}",
    ]
    condition {
      expression  = "resource.name == 'google_sql_database_instance.default.id' && resource.type == 'sqladmin.googleapis.com/Instance'"
      title       = "created"
      description = "Send notifications on creation events"
    }
  }
}

resource "google_project_iam_policy" "project" {
  project     = data.google_project.project.id
  policy_data = data.google_iam_policy.sql_iam_policy.policy_data
}
# [END cloud_sql_instance_iam_conditions]

resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-iam-condition"
  provider         = google-beta
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection =  "true"
}