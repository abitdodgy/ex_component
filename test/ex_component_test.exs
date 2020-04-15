defmodule ExComponentTest do
  use ExUnit.Case

  import Phoenix.HTML, only: [safe_to_string: 1]

  defmodule List do
    import ExComponent

    defcomp(:list, type: {:content_tag, :ul}, class: "list", variants: [:flush, :horizontal])
  end

  describe "defcomp with `:content_tag` type" do
    test "generates component with block" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result =
        List.list do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with block and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result =
        List.list class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with content" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result = List.list("Content")

      assert safe_to_string(result) == expected
    end

    test "generates component with content and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result = List.list("Content", class: "extra")

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant and block" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        List.list :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, opts and block" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result =
        List.list :flush, class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant and content" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result = List.list(:flush, "Content")

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, content and opts" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result = List.list(:flush, "Content", class: "extra")

      assert safe_to_string(result) == expected
    end

    test "with a variant list" do
      expected = ~s(<ul class=\"list list-flush list-horizontal\">Content</ul>)

      result = List.list("Content", variants: [:flush, :horizontal])

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `:tag` type" do
    defmodule Divider do
      import ExComponent

      defcomp(:divider, type: {:tag, :hr}, class: "divider", variants: [:sm, :lg])
    end

    test "generates component" do
      expected = ~s(<hr class=\"divider\">)

      result = Divider.divider()

      assert safe_to_string(result) == expected
    end

    test "generates component with opts" do
      expected = ~s(<hr class=\"divider extra\">)

      result = Divider.divider(class: "extra")

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant" do
      expected = ~s(<hr class=\"divider divider-sm\">)

      result = Divider.divider(:sm)

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant and opts" do
      expected = ~s(<hr class=\"divider divider-sm extra\">)

      result = Divider.divider(:sm, class: "extra")

      assert safe_to_string(result) == expected
    end

    test "with a variant list" do
      expected = ~s(<hr class=\"divider divider-sm divider-lg\">)

      result = Divider.divider(variants: [:sm, :lg])

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `:delegate` type" do
    defmodule Delegate do
      import ExComponent

      alias Phoenix.HTML.{Tag, Link}

      defcomp(:image, type: {:delegate, &Tag.img_tag/2}, class: "image")
      defcomp(:link, type: {:delegate, &Link.link/2}, class: "link")
    end

    test "delegates to the given function" do
      expected = ~s(<img class=\"image\" src="path">)

      result = Delegate.image("path")

      assert safe_to_string(result) == expected
    end

    test "delegates to the given function that uses a block" do
      expected = ~s(<a class="link" href=\"#\">Link!</a>)

      result = Delegate.link("Link!", to: "#")
      assert safe_to_string(result) == expected

      result = Delegate.link to: "#" do
        "Link!"
      end
      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp/3 with sibling options" do
    defmodule Siblings do
      import ExComponent

      defcomp(:alert_with_append,
        type: {:content_tag, :div},
        class: "alert",
        append: :hr,
        variants: [:success]
      )

      defcomp(:alert_with_prepend,
        type: {:content_tag, :div},
        class: "alert",
        prepend: :hr,
        variants: [:success]
      )

      defcomp(:alert_with_prepend_and_append,
        type: {:content_tag, :div},
        class: "alert",
        append: :hr,
        prepend: :hr,
        variants: [:success]
      )
    end

    test "with `:append` option" do
      expected = ~s(<div class=\"alert alert-success\">Alert!<hr></div>)

      result = Siblings.alert_with_append(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:prepend` option" do
      expected = ~s(<div class=\"alert alert-success\"><hr>Alert!</div>)

      result = Siblings.alert_with_prepend(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:append` and `:prepend` option" do
      expected = ~s(<div class=\"alert alert-success\"><hr>Alert!<hr></div>)

      result = Siblings.alert_with_prepend_and_append(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "overrides `:append` option with opts" do
      expected = ~s(<div class=\"alert alert-success\">Alert!<br></div>)

      result = Siblings.alert_with_append(:success, "Alert!", append: :br)

      assert safe_to_string(result) == expected
    end

    test "overrides `:prepend` option with opts" do
      expected = ~s(<div class=\"alert alert-success\"><br>Alert!</div>)

      result = Siblings.alert_with_prepend(:success, "Alert!", prepend: :br)

      assert safe_to_string(result) == expected
    end

    test "overrides `:append` and `:prepend` options with opts" do
      expected = ~s(<div class=\"alert alert-success\"><br>Alert!<br></div>)

      result = Siblings.alert_with_prepend(:success, "Alert!", append: :br, prepend: :br)

      assert safe_to_string(result) == expected
    end

    test "accepts binary"
    test "accepts function"
  end

  test "defcomp with `:tag` opt overrides default tag" do
    expected = ~s(<ol class=\"list\">Content</ol>)

    result = List.list("Content", tag: :ol)

    assert safe_to_string(result) == expected
  end

  test "with `:nest` option"
  test "with `:delegate` opt"
  test "with `:variants` opt"
end
