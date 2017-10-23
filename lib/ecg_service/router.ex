defmodule EcgService.Router do
  use Plug.Router
  require Logger

  plug Plug.RequestId # Must be before Plug.Logger
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "ecg-service")
  end

  get "/beam/:beam_file/dot" do
    conn = Plug.Conn.fetch_query_params conn
    params = conn.query_params
    Logger.info "params: #{inspect params}"
    payload = params["payload"]
    Logger.info "payload: #{payload}"
    try do
      beam = payload
             |> Base.decode64!()
             |> inflate!()
      dot = beam_to_dot(beam_file, beam)
      send_resp(conn, 200, dot)
    rescue
      ex -> Logger.error "error #{inspect(ex)} request payload #{payload}"
            send_resp(conn, 500, "")
    end
  end

  post "/beam/:beam_file/dot" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    try do
      dot = beam_to_dot(beam_file, body)
      send_resp(conn, 200, dot)
    rescue
      ex -> Logger.error "error #{inspect(ex)} request body #{body}"
            send_resp(conn, 500, "")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  def beam_to_dot(name, beam) do
    ## TODO: find a Linux compatible invocation
    {tmpdir, 0} = System.cmd("mktemp", ["-d"])
    tmpfile = tmpdir
              |> String.trim()
              |> Path.join("#{name}.beam")
    try do
      :ok = File.write(tmpfile, beam)
      :ecg.run(name, ['#{tmpfile}'])
    after
      File.rm_rf(tmpdir)
    end
  end

  def inflate!(deflated) do
    z = :zlib.open()
    :zlib.inflateInit(z)
    inflated = :zlib.inflate(z, deflated)
    :zlib.close(z)
    inflated
  end

end
