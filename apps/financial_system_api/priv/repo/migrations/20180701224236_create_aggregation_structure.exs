defmodule FinancialSystemApi.Repo.Migrations.CreateAggregationStructure do
  use Ecto.Migration

  def up do
    do_execute("create_rollups_table.sql")
    do_execute("insert_into_rollup_table.sql")
    do_execute("create_incremental_rollup_window_function.sql")
    do_execute("create_transactions_1day_table.sql")
    do_execute("create_do_transactions_aggregations_function.sql")
  end

  def down do
    do_execute("drop_rollups_table.sql")
    do_execute("drop_transactions_1day_table.sql")
  end

  defp do_execute(file_name) do
    :financial_system_api
    |> :code.priv_dir()
    |> Path.join("repo/scripts/#{file_name}")
    |> File.read!()
    |> execute()
  end
end
