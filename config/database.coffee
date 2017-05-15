env_http = process.env.JUGGLINGDB_HTTP_ENV
env_user = process.env.JUGGLINGDB_USER_ENV
env_pass = process.env.JUGGLINGDB_PASS_ENV
env_host = process.env.JUGGLINGDB_HOST_ENV
env_database = process.env.JUGGLINGDB_DATABASE_ENV
env_driver = process.env.JUGGLINGDB_DRIVER_ENV

if env_http and env_user and env_pass and env_host and env_database and env_driver
  envurl= "#{env_http}#{env_user}:#{env_pass}@#{env_host}/#{env_database}"

# REPLACE HERE WITH YOUR CONFIG
myURL = envurl or "http://user:password@localhost:5984/database_name"

myDriver = env_driver or "nano"

# console.info "Driver: #{myDriver}"
# console.info "Url: #{myURL}"

module.exports =
  development:
    #driver: "memory"
    driver: myDriver
    url: myURL
    request_defaults :
      strictSSL : false

  test:
    driver: "memory"

  production:
    # driver: "memory"
    driver: myDriver
    url: myURL
    request_defaults :
      strictSSL : false