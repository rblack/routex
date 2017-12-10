defmodule Routex.Storage do
  @type ip_address_v4 :: {0..255, 0..255, 0..255, 0..255,}
  @type ip_address_v6 :: {0..65535,
                           0..65535,
                           0..65535,
                           0..65535,
                           0..65535,
                           0..65535,
                           0..65535,
                           0..65535,
                           0..65535}
  @type ip_address :: ip_address_v4 | ip_address_v6
  @type ttl :: non_neg_integer
  @type mx_priority :: pos_integer
  @type hostname :: list
  @type record :: {ip_address, ttl} | {{mx_priority, hostname}, ttl}
  @type dns_data :: [record]

  @spec get(hostname, atom) :: list | nil
  def get(domain, type) do
    d = %{
      'hello.com' =>
        %{
          a: [
            {{192,168,0,22}, 60}
          ],
          aaaa: [
            {{9216, 51968, 0, 0, 0, 0, 0, 0}, 60}
          ],
          mx: [
            {{10, 'hello_world.com'}, 60}
          ],
        }
    }
    d[domain][type]
  end
end