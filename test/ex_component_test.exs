defmodule ExComponentTest do
  use ExUnit.Case

  import ExComponent
  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "defcomp with `arity: 2`" do
    defmodule Default do
      defcomp(:list, render: {:tag, :ul}, class: "list")
    end

    test "generates component with block" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result =
        Default.list do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with block and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result =
        Default.list class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with content" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result = Default.list("Content")

      assert safe_to_string(result) == expected
    end

    test "generates component with content and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result = Default.list("Content", class: "extra")

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `arity: 2` and block false" do
    defmodule NoBlock do
      defcomp(:list, render: {:tag, :ul}, block: false, class: "list")
    end

    test "generates component with content" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result = NoBlock.list("Content")

      assert safe_to_string(result) == expected
    end

    test "generates component with content and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result = NoBlock.list("Content", class: "extra")

      assert safe_to_string(result) == expected
    end

    test "raises when given a block" do
      assert_raise ArgumentError, fn ->
        NoBlock.list do
          "Content"
        end
      end
    end

    test "raises when given a block and opts" do
      assert_raise ArgumentError, fn ->
        NoBlock.list class: "extra" do
          "Content"
        end
      end
    end
  end

  describe "defcomp with `arity: 2` and `block: :only`" do
    defmodule BlockOnly do
      defcomp(:list, render: {:tag, :ul}, block: :only, class: "list")
    end

    test "generates component with a block" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result =
        BlockOnly.list do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with a block and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result =
        BlockOnly.list class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "raises when given content" do
      assert_raise FunctionClauseError, fn ->
        BlockOnly.list("Content")
      end
    end

    test "raises when given content and opts" do
      assert_raise FunctionClauseError, fn ->
        BlockOnly.list("Content", class: "extra")
      end
    end
  end

  describe "defcomp with `arity: 3`" do
    defmodule ArityThreeDefault do
      defcomp(:list, render: {:tag, :ul}, class: "list", variants: [:flush, :horizontal])
    end

    test "generates component with atom variant and block" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        ArityThreeDefault.list :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, opts and block" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result =
        ArityThreeDefault.list :flush, class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant and content" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result = ArityThreeDefault.list(:flush, "Content")

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, content and opts" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result = ArityThreeDefault.list(:flush, "Content", class: "extra")

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `arity: 3` with `block: only`" do
    defmodule ArityThreeBlockOnly do
      defcomp(:list,
        render: {:tag, :ul},
        block: :only,
        class: "list",
        variants: [:flush, :horizontal]
      )
    end

    test "generates component with atom variant and block" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        ArityThreeBlockOnly.list :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, opts and block" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result =
        ArityThreeBlockOnly.list :flush, class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "raises when given content" do
      assert_raise FunctionClauseError, fn ->
        ArityThreeBlockOnly.list(:flush, "Content")
      end
    end

    test "raises when given content and opts" do
      assert_raise FunctionClauseError, fn ->
        ArityThreeBlockOnly.list("Content", class: "extra")
      end
    end
  end

  describe "with tag option" do
    defmodule F do
      defcomp(:list, render: {:tag, :ul}, class: "list")
    end

    test "generates component with a custom tag" do
      expected = ~s(<div class=\"list\">Content</div>)

      result =
        F.list tag: :div do
          "Content"
        end

      assert safe_to_string(result) == expected
    end
  end

  describe "with component delegate option" do
    defmodule Delegate do
      alias Phoenix.HTML.Tag
      defcomp(:image, render: {:delegate, &Tag.img_tag/2}, class: "image")
    end

    test "delegates to the given function" do
      expected = ~s(<img class=\"image\" src="path">)

      result = Delegate.image("path")

      assert safe_to_string(result) == expected
    end
  end

  # describe "with function delegate option" do
  #   alias Phoenix.HTML.{Tag, Link}

  #   defmodule H do
  #     defcomp(:link, render: {:delegate, &Link.link/2}, class: "link")
  #   end

  #   test "overrides delegate in component definition" do
  #     expected = ~s(<img class="link" src="path">)
  #     result = H.link("path", tag: &Tag.img_tag/2)

  #     assert safe_to_string(result) == expected
  #   end
  # end

  describe "with variants option" do
    defmodule I do
      defcomp(:list, render: {:tag, :ul}, class: "list", variants: [:flush, :horizontal])
    end

    test "generates component with an atom variant option" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        I.list variants: :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with a list variant option" do
      expected = ~s(<ul class=\"list list-flush list-horizontal\">Content</ul>)

      result =
        I.list variants: [:flush, :horizontal] do
          "Content"
        end

      assert safe_to_string(result) == expected
    end
  end

  describe "with prepend option" do
    # defmodule Icon do
    #   defcomp(:icon, render: {:tag, :a}, class: "icon")
    # end

    # defmodule PrependContent do
    #   defcomp(:breadcrumb, render: {:tag, :ol}, class: "breadcrumb", prepend: Icon.icon("some-icon"))
    # end

    # test "prepends given content to the component" do
    #   expected = ~s(<ol class=\"breadcrumb\"><a class=\"icon\">some-icon</a>Content</ol>)

    #   result =
    #     PrependContent.breadcrumb do
    #       "Content"
    #     end

    #   assert safe_to_string(result) == expected
    # end

    defmodule PrependTag do
      defcomp(:breadcrumb, render: {:tag, :ol}, class: "breadcrumb", prepend: {:void, :hr})
    end

    test "prepends the given tag to the component" do
      expected = ~s(<ol class=\"breadcrumb\"><hr>Content</ol>)

      result =
        PrependTag.breadcrumb do
          "Content"
        end

      assert safe_to_string(result) == expected
    end
  end

  # describe "with `nest` option" do
  #   defmodule K do
  #     defcomp(:breadcrumb, class: "breadcrumb", nest: :nav, default_tag: :ol)
  #   end

  #   test "nests content in the given tage" do
  #     expected =
  #       ~s(<nav>) <>
  #         ~s(<ol class=\"breadcrumb\">Content</ol>) <>
  #         ~s(</nav>)

  #     result =
  #       K.breadcrumb do
  #         "Content"
  #       end

  #     assert safe_to_string(result) == expected
  #   end
  # end
end
