resource "aws_db_instance" "default" {
  allocated_storage       = 20
  db_name                 = local.db_name
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  username                = local.db_username
  password                = local.db_password
  skip_final_snapshot     = true
  backup_retention_period = 0
  storage_encrypted       = true
  apply_immediately       = true
  publicly_accessible     = true
  db_subnet_group_name    = module.vpc.database_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.db.id]

  depends_on = [module.vpc]
}
