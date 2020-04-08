defmodule ExComponentTest do
  use ExUnit.Case

  import ExComponent
  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "defcomp with `arity: 2`" do
    defmodule A do
      defcomp(:list, class: "list", default_tag: :ul, variants: [:flush, :horizontal])
    end

    test "generates component with block" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result =
        A.list do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with block and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result =
        A.list class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with content" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result = A.list "Content"

      assert safe_to_string(result) == expected
    end

    test "generates component with content and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result = A.list "Content", class: "extra"

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `arity: 2` and block false" do
    defmodule B do
      defcomp(:list, block: false, class: "list", default_tag: :ul, variants: [:flush, :horizontal])
    end

    test "generates component with content" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result = B.list "Content"

      assert safe_to_string(result) == expected
    end

    test "generates component with content and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result = B.list "Content", class: "extra"

      assert safe_to_string(result) == expected
    end

    test "raises when given a block" do
      assert_raise ArgumentError, fn ->
        B.list do
          "Content"
        end
      end
    end

    test "raises when given a block and opts" do
      assert_raise ArgumentError, fn ->
        B.list class: "extra" do
          "Content"
        end
      end
    end
  end

  describe "defcomp with `arity: 2` and `block: :only`" do
    defmodule C do
      defcomp(:list, block: :only, class: "list", default_tag: :ul, variants: [:flush, :horizontal])
    end

    test "generates component with a block" do
      expected = ~s(<ul class=\"list\">Content</ul>)

      result =
        C.list do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with a block and opts" do
      expected = ~s(<ul class=\"list extra\">Content</ul>)

      result =
        C.list class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "raises when given content" do
      assert_raise FunctionClauseError, fn ->
        C.list "Content"
      end
    end

    test "raises when given content and opts" do
      assert_raise FunctionClauseError, fn ->
        C.list "Content", class: "extra"
      end
    end
  end

  describe "defcomp with `arity: 3`" do
    defmodule D do
      defcomp(:list, class: "list", default_tag: :ul, variants: [:flush, :horizontal])
    end

    test "generates component with atom variant and block" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        D.list :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, opts and block" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result =
        D.list :flush, class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant and content" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result = D.list :flush, "Content"

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, content and opts" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result = D.list :flush, "Content", class: "extra"

      assert safe_to_string(result) == expected
    end
  end

  describe "defcomp with `arity: 3` with `block: only`" do
    defmodule E do
      defcomp(:list, block: :only, class: "list", default_tag: :ul, variants: [:flush, :horizontal])
    end

    test "generates component with atom variant and block" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result =
        E.list :flush do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "generates component with atom variant, opts and block" do
      expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

      result =
        E.list :flush, class: "extra" do
          "Content"
        end

      assert safe_to_string(result) == expected
    end

    test "raises when given content" do
      assert_raise FunctionClauseError, fn ->
        E.list :flush, "Content"
      end
    end

    test "raises when given content and opts" do
      assert_raise FunctionClauseError, fn ->
        E.list "Content", class: "extra"
      end
    end
  end

  describe "with tag option" do
    defmodule F do
      defcomp(:list, class: "list", default_tag: :ul)
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
    defmodule G do
      defcomp(:image, class: "image", delegate: &Phoenix.HTML.Tag.img_tag/2)
    end

    test "delegates to the given function" do
      expected = ~s(<img class=\"image\" src="path">)

      result = G.image("path")

      assert safe_to_string(result) == expected
    end
  end

  describe "with function delegate option" do
    defmodule H do
      defcomp(:link, class: "link", delegate: &Phoenix.HTML.Link.link/2)
    end

    test "overrides delegate in component definition" do
      expected = ~s(<img class="link" src="path">)

      result = H.link("path", delegate: &Phoenix.HTML.Tag.img_tag/2)

      assert safe_to_string(result) == expected
    end
  end

  describe "with variants option" do
    defmodule I do
      defcomp(:list, class: "list", default_tag: :ul, variants: [:flush, :horizontal])
    end

    test "generates component with an atom variant option" do
      expected = ~s(<ul class=\"list list-flush\">Content</ul>)

      result = I.list variant: :flush do
        "Content"
      end

      assert safe_to_string(result) == expected
    end

    test "generates component with a list variant option" do
      expected = ~s(<ul class=\"list list-flush list-horizontal\">Content</ul>)

      result = I.list variant: [:flush, :horizontal]  do
        "Content"
      end

      assert safe_to_string(result) == expected
    end
  end

  describe "with prepend option" do
    test "prepends given content to the component"
  end

    # test "generates component with tuple variant and block" do
    #   expected = ~s(<ul class=\"list list-flush list-horizontal\">Content</ul>)

    #   result =
    #     A.list {:flush, :horizontal} do
    #       "Content"
    #     end

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with atom variant, opts and block" do
    #   expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

    #   result =
    #     A.list :flush, class: "extra" do
    #       "Content"
    #     end

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with tuple variant, opts and block" do
    #   expected = ~s(<ul class=\"list list-flush list-horizontal extra\">Content</ul>)

    #   result =
    #     A.list {:flush, :horizontal}, class: "extra" do
    #       "Content"
    #     end

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with content" do
    #   expected = ~s(<ul class=\"list\">Content</ul>)

    #   result = A.list "Content"

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with content and opts" do
    #   expected = ~s(<ul class=\"list extra\">Content</ul>)

    #   result = A.list "Content", class: "extra"

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with atom variant and content" do
    #   expected = ~s(<ul class=\"list list-flush\">Content</ul>)

    #   result = A.list :flush, "Content"

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with atom variant, content and opts" do
    #   expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

    #   result = A.list :flush, "Content", class: "extra"

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with tuple variant and content" do
    #   expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

    #   result = A.list {:flush, :horizontal}, "Content"

    #   assert safe_to_string(result) == expected
    # end

    # test "generates component with tuple variant, content and opts" do
    #   expected = ~s(<ul class=\"list list-flush extra\">Content</ul>)

    #   result = A.list {:flush, :horizontal}, "Content", class: "extra"

    #   assert safe_to_string(result) == expected
    # end



end
