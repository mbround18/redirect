# Redirect

Extremely lightweight redirecting agent that uses less than 5MB ram to run redirections. For an example visit [links.boop.ninja/github](https://links.boop.ninja/github)

## Usage

1. Set ENV Variable `REDIRECTS`
   1. Examples:
      ```shell
      REDIRECTS="google>https://google.com|discord>https://discord.gg/d5N7JwzPgt" 
       ```
   > NOTE! both `>` and `|` are not URL safe, these are used to designate how the app breaks the variable up. 
   > You can include newlines in the variable to make it easier to read. If your url uses `>` or `|` please url encode it!

2.  Set ENV variable `DEFAULT_ENDPOINT` to point to the url you which to direct any other traffic towards. 
3. Launch the redirect agent. 

