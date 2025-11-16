# Excluir tests de performance por defecto
ExUnit.start(exclude: [:performance])

# Configuración adicional
ExUnit.configure(
  timeout: 120_000,
  max_failures: 5,
  formatters: [ExUnit.CLIFormatter]
)

IO.puts("\n═══════════════════════════════════════════")
IO.puts("   Test Suite Iniciado")
IO.puts("═══════════════════════════════════════════")
IO.puts("  Para ejecutar tests de performance:")
IO.puts("  mix test --only performance")
IO.puts("═══════════════════════════════════════════\n")
