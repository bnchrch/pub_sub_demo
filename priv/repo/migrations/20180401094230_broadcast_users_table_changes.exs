defmodule PubSubDemo.Repo.Migrations.BroadcastUsersTableChanges do
  use Ecto.Migration

  def up do
    execute "
      CREATE OR REPLACE FUNCTION broadcast_changes()
      RETURNS trigger AS $$
      DECLARE
        current_row RECORD;
      BEGIN
        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
          current_row := NEW;
        ELSE
          current_row := OLD;
        END IF;
      PERFORM pg_notify(
          'users_changes',
          json_build_object(
            'table', TG_TABLE_NAME,
            'type', TG_OP,
            'id', current_row.id,
            'data', row_to_json(current_row)
          )::text
        );
      RETURN current_row;
      END;
      $$ LANGUAGE plpgsql;"

    execute "
      CREATE TRIGGER notify_user_changes_trigger
      AFTER INSERT OR UPDATE OR DELETE
      ON users
      FOR EACH ROW
      EXECUTE PROCEDURE broadcast_changes();"
  end

  def down do
    execute "DROP TRIGGER notify_user_changes_trigger"
  end
end
