defmodule ApiWeb.Token do
  use Joken.Config

  # Fetch the secret key and decode it only at runtime
  defp fetch_secret_key() do
    secret_key = System.get_env("JWT_SECRET")

    if secret_key do
      case Base.decode64(secret_key) do
        {:ok, decoded_key} -> decoded_key
        :error -> raise "Invalid JWT_SECRET: not a valid Base64 string."
      end
    else
      raise "JWT_SECRET environment variable is not set."
    end
  end

  # Function to generate a token for the user
  def generate_token(user) do
    # Define the current time and add 15 days (15 * 24 * 60 * 60 seconds)
    thirty_days_from_now = Joken.current_time() + 1296000

    # Convert the current time to a DateTime struct to manipulate hours
    expiration_time = DateTime.from_unix!(thirty_days_from_now)

    # Adjust the expiration time to 1 AM (keeping the same day after 15 days)
    expiration_at_1_am = expiration_time
      |> DateTime.to_date()  # Get the date 15 days from now
      |> DateTime.new!(~T[01:00:00], expiration_time.time_zone)  # Set time to 01:00:00 AM

    # Get the new expiration timestamp
    exp_timestamp = DateTime.to_unix(expiration_at_1_am)

    # Define the payload with user information and the adjusted expiration time
    claims = %{
      "user_id" => user.id,
      "exp" => exp_timestamp  # Token will expire at 1 AM after 15 days
    }

    # Use the secret to create a token with a signer
    signer = Joken.Signer.create("HS256", fetch_secret_key())

    # Generate the token
    {:ok, token, _claims} = Joken.encode_and_sign(claims, signer)
    token
  end

  # Function to verify the token
  def verify_token(token) do
    # Use the secret to create a token signer
    signer = Joken.Signer.create("HS256", fetch_secret_key())

    # Verify the token
    Joken.verify_and_validate(token, signer)
  end
end
