from django.db import connections


def run_sql(dbalias, filename):
    connection = connections[dbalias]

    with open(filename, 'r') as sql_file:
        sql = sql_file.read()
        with connection.cursor() as cursor:
            cursor.execute(sql)
