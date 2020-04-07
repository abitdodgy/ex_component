defmodule ExComponentTest do
  use ExUnit.Case

  # doctest ExComponent

  import Phoenix.HTML, only: [safe_to_string: 1]

  defmodule Dummy do
    import ExComponent

    defcomp(:list,
      block: :block_only,
      class: "list",
      default_tag: :ul,
      variants: [:flush, :horizontal]
    )

    defcomp(:list_item, class: "list-item", default_tag: :li, variants: [:primary, :action])
    defcomp(:card_image, block: false, class: "card-image", default_tag: :img)

    defcomp(:badge, arity: 3, class: "badge", default_tag: :span, variants: [:primary, :secondary])

    defcomp(:my_list,
      arity: 3,
      block: :block_only,
      class: "list",
      default_tag: :ul,
      variants: [:primary, :secondary]
    )
  end

  describe "defcomp/2 with `arity: 2` and `block: :block_only`" do
    test "generates the component" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result =
        Dummy.list do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "accepts a list of options" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result =
        Dummy.list class: :extra do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "raises when given content" do
      assert_raise FunctionClauseError, fn ->
        Dummy.list("Content!")
      end
    end

    test "raises when given content and options" do
      assert_raise FunctionClauseError, fn ->
        Dummy.list("Content!", class: :extra)
      end
    end

    test "accepts atom `variant` option" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        Dummy.list variant: :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "accepts list `variant` option" do
      expected = ~s(<ul class=\"list list-flush list-horizontal\">Content</ul>)

      result =
        Dummy.list variant: [:flush, :horizontal] do
          "Content"
        end

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp/2 with `arity: 2` and `block: true`" do
    test "generates the component" do
      expected = ~s(<li class=\"list-item\">Item!</li>)

      result =
        Dummy.list_item do
          "Item!"
        end

      assert safe_to_string(result) == expected
    end

    test "accepts a list of options" do
      expected = ~s(<li class=\"list-item extra\">Item!</li>)

      result =
        Dummy.list_item class: "extra" do
          "Item!"
        end

      assert safe_to_string(result) == expected
    end

    test "accepts content" do
      expected = ~s(<li class=\"list-item\">Content</li>)

      result = Dummy.list_item("Content")

      assert safe_to_string(result) == expected
    end

    test "accepts content with options" do
      expected = ~s(<li class=\"list-item extra\">Content</li>)

      result = Dummy.list_item("Content", class: "extra")

      assert safe_to_string(result) == expected
    end

    test "accepts atom `variant` option" do
      expected = ~s(<li class=\"list-item list-item-primary\">Content</li>)

      result =
        Dummy.list_item variant: :primary do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "accepts list `variant` option" do
      expected = ~s(<li class=\"list-item list-item-action list-item-primary\">Content</li>)

      result =
        Dummy.list_item variant: [:action, :primary] do
          "Content"
        end

      assert safe_to_string(result) == expected
    end
  end

  describe "with function delegation" do
    test "delegates to the given function" do
      expected = ~s(<a class=\"list-item\" href=\"#\">Link!</a>)

      result = Dummy.list_item("Link!", to: "#", delegate: &Phoenix.HTML.Link.link/2)

      assert safe_to_string(result) == expected
    end

    test "delegates to the given function with a block" do
      expected = ~s(<a class=\"list-item\" href=\"#\">Link!</a>)

      result =
        Dummy.list_item to: "#", delegate: &Phoenix.HTML.Link.link/2 do
          "Link!"
        end

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp/2 with `arity` 2 and `:no_block`" do
    test "generates the component" do
      expected = ~s(<img class=\"card-image\")

      result = Dummy.card_image("path")

      assert safe_to_string(result) =~ expected
    end

    test "accepts a list of options" do
      expected = ~s(<img class=\"card-image\")

      result = Dummy.card_image("path", variant: :top)

      assert safe_to_string(result) =~ expected
    end

    test "raises when given a block" do
      assert_raise ArgumentError, fn ->
        Dummy.card_image do
          "path"
        end
      end
    end

    test "raises when given a block and options" do
      assert_raise ArgumentError, fn ->
        Dummy.card_image class: "extra" do
          "path"
        end
      end
    end
  end

  describe "defcomp with `arity: 3`" do
    test "generates the component" do
      expected = ~s(<span class=\"badge badge-primary\">Content</span>)

      result = Dummy.badge(:primary, "Content")

      assert safe_to_string(result) == expected
    end

    test "accepts a list of options" do
      expected = ~s(<span class=\"badge badge-primary extra\">Content</span>)

      result = Dummy.badge(:primary, "Content", class: "extra")

      assert safe_to_string(result) == expected
    end

    test "accepts a block" do
      expected = ~s(<span class=\"badge badge-primary\">Content</span>)

      result =
        Dummy.badge :primary do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "accepts a with options" do
      expected = ~s(<span class=\"badge badge-primary extra\">Content</span>)

      result =
        Dummy.badge :primary, class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end
  end

  test "arity/3 :block_only" do
    expected = ~s(<ul class=\"list list-primary\">Content</ul>)

    result =
      Dummy.my_list :primary do
        "Content"
      end

    assert safe_to_string(result) == expected
  end

  test "arity/3 false"
end
