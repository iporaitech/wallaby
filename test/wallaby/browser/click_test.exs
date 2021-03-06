defmodule Wallaby.Browser.ClickTest do
  use Wallaby.SessionCase, async: true

  setup %{session: session} do
    page = visit(session, "forms.html")

    {:ok, %{page: page}}
  end

  describe "click/2" do
    test "accepts queries", %{page: page} do
      assert page
      |> click(Query.button("Submit button"))
    end

    test "can click invisible elements", %{page: page} do
      assert page
      |> click(Query.button("Invisible Button", visible: false))
    end

    test "can be chained/returns parent", %{page: page} do
      page
      |> click(Query.css("#option1"))
      |> click(Query.css("#option2"))

      assert selected?(page, Query.css("#option2"))
    end
  end

  describe "click/2 with radio buttons (choose replacement)" do
    test "choosing a radio button", %{page: page} do
      refute selected?(page, Query.css("#option2"))

      page
      |> click(Query.radio_button("option2"))

      assert selected?(page, Query.css("#option2"))
    end

    test "choosing a radio button unchecks other buttons in the group", %{page: page} do
      page
      |> click(Query.radio_button("Option 1"))
      |> selected?(Query.css("#option1"))
      |> assert

      page
      |> click(Query.radio_button("option2"))

      refute selected?(page, Query.css("#option1"))
      assert selected?(page, Query.css("#option2"))
    end

    test "throw an error if a label exists but does not have a for attribute", %{page: page} do
      bad_form =
        page
        |> find(Query.css(".bad-form"))

      assert_raise Wallaby.QueryError, fn ->
        click(bad_form, Query.radio_button("Radio with bad label"))
      end
    end

    test "waits until the radio button appears", %{page: page} do
      assert click(page, Query.radio_button("Hidden Radio Button"))
    end

    test "escape quotes", %{page: page} do
      assert click(page, Query.radio_button("I'm a radio button"))
    end
  end
end
