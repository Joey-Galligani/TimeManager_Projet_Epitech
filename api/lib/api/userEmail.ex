defmodule Api.UserEmail do
  import Swoosh.Email
  import Dotenvy

  def reset_key_email(to_email, reset_key) do
    from_email = env!("SMTP_USERNAME", :string!)
    IO.puts("From email: #{from_email}")

    new()
    |> to(to_email)
    |> from(from_email)
    |> subject("Your Reset Key")
    |> text_body("Your reset key is #{reset_key}")
  end

end
