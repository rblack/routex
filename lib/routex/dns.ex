defmodule Routex.DNS do
  require Logger
  @rc_disp %{0 => "NOERROR", 5 => "REFUSED"}
  @rc %{
    noerror: 0,
    refused: 5,
  }

  @spec make_resp(binary) :: binary
  def make_resp(packet) do
    rec = DNS.Record.decode(packet)
    query = hd(rec.qdlist)
    {rr, rcode} = get_resource(query)
    rec = %{rec|anlist: rr}
    query_id = rec.header.id
    rec = %{rec|header: %DNS.Header{aa: false, id: query_id, opcode: :query, pr: false, qr: false,
      ra: false, rcode: rcode, rd: true, tc: false}}
    Logger.info("Query id: #{rec.header.id}, domain: #{query.domain}, status: #{@rc_disp[rcode]}")
    DNS.Record.encode(rec)
  end

  defp get_resource(%DNS.Query{} = q) do
    results = Routex.Storage.get(q.domain, q.type)
    case results do
      nil ->
        {[], @rc.refused}
      res ->
        resources = Enum.map(results, fn
          {dns_data, ttl} ->
            %DNS.Resource{
              domain: q.domain,
              class: q.class,
              type: q.type,
              ttl: ttl,
              data: dns_data
            }
        end)
        {resources, @rc.noerror}
    end

  end

  defp get_resource(_) do
    {[], @rc.refused}
  end

end
