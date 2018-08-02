# config/.credo.exs
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "rel/", "config/", "apps/"],
        excluded: ["apps/**/assets/*"]
      },
      checks: [
        # For others you can also set parameters
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 80}
      ]
    }
  ]
}
