%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        #
        ## CredoNaming
        #
        {CredoNaming.Check.Consistency.ModuleFilename}
      ]
    }
  ]
}
