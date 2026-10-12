locals {
  data_path = "/opt/stacks/postgres/data"
  # Пользователь внутри контейнера: postgres (999/999)
  # Пользователь внутри образа alpine: postgres (70/70)
  user = {
    uid = 70
    gid = 70
  }
}
