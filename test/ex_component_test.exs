defmodule ExComponentTest do
  use ExUnit.Case

  import ExComponent, only: [render: 2, render: 3]

  defp assert_safe(result, expected) do
    assert Phoenix.HTML.safe_to_string(result) == expected
  end

  describe "render/2" do
    @options [tag: :hr, class: "divider", variants: [:lg]]

    test "renders given component" do
      assert_safe render([], @options), ~s(<hr class="divider">)
    end

    test "accepts a list of options" do
      assert_safe render([class: "extra"], @options), ~s(<hr class="divider extra">)
    end
  end

  describe "render/3" do
    @options [tag: :ul, class: "list", variants: [:horizontal]]

    test "renders given component" do
      result = render("Content", [], @options)
      assert_safe result, ~s(<ul class="list">Content</ul>)
    end

    test "renders given component with block" do
      expected = ~s(<ul class="list">Content</ul>)

      result =
        render [], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a list of options" do
      expected = ~s(<ul class="list extra">Content</ul>)

      result =
        render [class: "extra"], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a tag option" do
      expected = ~s(<div class="list">Content</div>)

      result =
        render [tag: :div], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a variants option" do
      expected = ~s(<ul class="list list-horizontal">Content</ul>)

      result =
        render [variants: [:horizontal]], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts custom variant_class_prefix option" do
      expected = ~s(<ul class="dropdown custom-dropup">Content</ul>)

      options = [class: "dropdown", tag: :ul, variants: [:dropup], variant_class_prefix: "custom"]

      result =
        render [variants: :dropup], options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts variant_class_prefix false option" do
      expected = ~s(<ul class="dropdown dropup">Content</ul>)

      options = [class: "dropdown", tag: :ul, variants: [:dropup], variant_class_prefix: false]

      result =
        render [variants: :dropup], options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a prepend option" do
      expected = ~s(<ul class="list"><hr>Content</ul>)

      result =
        render [prepend: {:hr, []}], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a prepend atom option" do
      expected = ~s(<ul class="list"><hr>Content</ul>)

      result =
        render [prepend: :hr], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a prepend {:safe, ...} option" do
      expected = ~s(<ul class="list"><button class="close">&amp;times;</button>Content</ul>)

      close_button = Phoenix.HTML.Tag.content_tag(:button, "&times;", class: "close")

      result =
        render [prepend: close_button], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts an append option" do
      expected = ~s(<ul class="list">Content<hr></ul>)

      result =
        render [append: {:hr, []}], @options do
          "Content"
        end

      assert_safe result, expected
    end

    test "accepts a parent option" do
      expected = ~s(<div><ul class="list">Content</ul></div>)

      result =
        render [parent: {:div, []}], @options do
          "Content"
        end

      assert_safe result, expected
    end
  end

  describe "defcontenttag" do
    defmodule Dummy do
      import ExComponent

      defcontenttag(:list, tag: :ul, class: "list", variants: [:flush])
    end

    test "defines name/1 function clause for given component" do
      expected = ~s(<ul class="list">Content</ul>)

      result = Dummy.list("Content")

      assert_safe result, expected
    end

    test "defines name/2 function clause for given component" do
      expected = ~s(<ul class="list extra">Content</ul>)

      result = Dummy.list("Content", class: "extra")

      assert_safe result, expected
    end

    test "defines name/1 block function clause for given component" do
      expected = ~s(<ul class="list">Content</ul>)

      result =
        Dummy.list do
          "Content"
        end

      assert_safe result, expected
    end

    test "defines name/2 block function clause for given component" do
      expected = ~s(<ul class="list extra">Content</ul>)

      result =
        Dummy.list class: "extra" do
          "Content"
        end

      assert_safe result, expected
    end

    test "defines variant/2 function clause for given component" do
      expected = ~s(<ul class="list list-flush">Content</ul>)

      result = Dummy.list(:flush, "Content")

      assert_safe result, expected
    end

    test "defines variant/3 function clause for given component" do
      expected = ~s(<ul class="list list-flush extra">Content</ul>)

      result = Dummy.list(:flush, "Content", class: "extra")

      assert_safe result, expected
    end

    test "defines variant/2 block function clause for given component" do
      expected = ~s(<ul class="list list-flush">Content</ul>)

      result =
        Dummy.list :flush do
          "Content"
        end

      assert_safe result, expected
    end

    test "defines variant/3 block function clause for given component" do
      expected = ~s(<ul class="list list-flush extra">Content</ul>)

      result =
        Dummy.list :flush, class: "extra" do
          "Content"
        end

      assert_safe result, expected
    end
  end

  describe "deftag" do
    defmodule Void do
      import ExComponent

      deftag(:divider, tag: :hr, class: "divider", variants: [:lg])
    end

    test "defines name/1 function clause for given component" do
      result = Void.divider()
      assert_safe result, ~s(<hr class="divider">)
    end

    test "defines name/2 function clause for given component" do
      result = Void.divider(class: "extra")
      assert_safe result, ~s(<hr class="divider extra">)
    end

    test "defines variant/1 function clause for given component" do
      result = Void.divider(:lg)
      assert_safe result, ~s(<hr class="divider divider-lg">)
    end

    test "defines variant/2 function clause for given component" do
      result = Void.divider(:lg, class: "extra")
      assert_safe result, ~s(<hr class="divider divider-lg extra">)
    end
  end
end
