defmodule RoutexTest do
  use ExUnit.Case
  doctest Routex

  def lookup(domain, type) do
    :inet_res.lookup(domain, :in, type, nameservers: [{{127, 0, 0, 1}, 1515}])
  end

  test "a rec" do
    res = lookup('hello.com', :a)
    assert res == [{192, 168, 0, 22}]
  end

  test "aaaa rec" do
    res = lookup('hello.com', :aaaa)
    assert res == [{9216, 51968, 0, 0, 0, 0, 0, 0}]
  end

  test "mx rec" do
    res = lookup('hello.com', :mx)
    assert res == [{10, 'hello_world.com'}]
  end

  test "non-existent type" do
    res = lookup('hello.com', :ptr)
    assert res == []
  end

  test "non-existent domain" do
    res = lookup('noname.hell', :a)
    assert res == []
  end
end
