resource "mongodbatlas_cloud_backup_schedule" "atlas_test_policies" {
  project_id   = module.atlas.atlas_project_id
  cluster_name = mongodbatlas_advanced_cluster.cluster.name

  reference_hour_of_day    = 2  // UTC Hour of day between 0 and 23, inclusive, representing which hour of the day that Atlas takes snapshots for backup policy items.
  reference_minute_of_hour = 10 // UTC Minutes after reference_hour_of_day that Atlas takes snapshots for backup policy items. Must be between 0 and 59, inclusive.
  restore_window_days      = 1 /* Number of days back in time you can restore to with point-in-time accuracy.
                                   Records the full oplog for a configured window, permitting a restore to any point in time within that window. 
                                   Must be a positive, non-zero integer.*/

  // This will now add the desired policy items to the existing mongodbatlas_cloud_backup_schedule resource
  policy_item_hourly {
    frequency_interval = 1      //  Desired frequency of the new backup policy item specified by frequency_type
    retention_unit     = "days" //  Scope of the backup policy item: days, weeks, or months.
    retention_value    = 2      //  Value to associate with retention_unit
  }
  policy_item_daily {
    frequency_interval = 1
    retention_unit     = "days"
    retention_value    = 7
  }
  policy_item_weekly {
    frequency_interval = 4
    retention_unit     = "weeks"
    retention_value    = 4
  }
  policy_item_monthly {
    frequency_interval = 5
    retention_unit     = "months"
    retention_value    = 12
  }
  depends_on = [mongodbatlas_advanced_cluster.cluster]
}