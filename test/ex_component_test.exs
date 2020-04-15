defmodule ExComponentTest do
  use ExUnit.Case

  import ExComponent
  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "defcomp with `:content_tag` type" do
    defmodule List do
      defcomp(:list, type: {:content_tag, :ul}, class: "list", variants: [:flush, :horizontal])
    end

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
  end

  describe "defcomp with `:tag` type" do
    defmodule Divider do
      defcomp(:divider, type: {:tag, :hr}, class: "divider", variants: [:sm, :lg])
    end

    test "generates component" do
      expected = ~s(<hr class=\"divider\">)

      result = Divider.divider

      assert safe_to_string(result) == expected
    end

    test "generates component with opts" do
      expected = ~s(<hr class=\"divider extra\">)

      result = Divider.divider class: "extra"

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant" do
      expected = ~s(<hr class=\"divider divider-sm\">)

      result = Divider.divider :sm

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant and opts" do
      expected = ~s(<hr class=\"divider divider-sm extra\">)

      result = Divider.divider :sm, class: "extra"

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `:delegate` type" do
    defmodule Delegate do
      alias Phoenix.HTML.Tag
      defcomp(:image, type: {:delegate, &Tag.img_tag/2}, class: "image")
    end

    test "delegates to the given function" do
      expected = ~s(<img class=\"image\" src="path">)

      result = Delegate.image("path")

      assert safe_to_string(result) == expected
    end
  end

  test "with `:append` option"
  test "with `:prepend` option"
  test "with `:nest` option"

  test "with `:tag` opt"
  test "with `:delegate` opt"
  test "with `:variants` opt"
end
