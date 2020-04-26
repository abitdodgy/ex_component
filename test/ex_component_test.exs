defmodule ExComponentTest do
  use ExUnit.Case

  import ExComponent, only: [render: 2, render: 3]

  defp assert_safe(result, expected) do
    assert Phoenix.HTML.safe_to_string(result) == expected
  end

  describe "deftag/2" do
    defmodule Tag do
      import ExComponent

      deftag(:divider, tag: :hr, class: "divider", variants: [lg: [class: "lg"]])
    end

    test "defines name/0 function for the given component" do
      assert_safe Tag.divider(), ~s(<hr class="divider">)
    end

    test "defines variant/1 function for the given component" do
      result = Tag.divider(:lg)
      assert_safe result, ~s(<hr class="divider divider-lg">)
    end

    test "defines a name/1 function for the given component" do
      result = Tag.divider(class: "extra")
      assert_safe result, ~s(<hr class="divider extra">)
    end

    test "defines a variant/2 function for the given component" do
      result = Tag.divider(:lg, class: "extra")
      assert_safe result, ~s(<hr class="divider divider-lg extra">)
    end

    test "accepts an atom tag option" do
      result = Tag.divider(tag: :br)
      assert_safe result, ~s(<br class="divider">)
    end
  end

  describe "defcontenttag" do
    defmodule ContentTag do
      import ExComponent

      defcontenttag(:list, tag: :ul, class: "list", variants: [flush: [class: "flush"]])
    end

    test "defines name/1 function for given component" do
      expected = ~s(<ul class="list">Content</ul>)

      result = ContentTag.list("Content")

      assert_safe(result, expected)
    end

    test "defines name/1 block function for given component" do
      expected = ~s(<ul class="list">Content</ul>)

      result =
        ContentTag.list do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "defines name/2 function for given component" do
      expected = ~s(<ul class="list extra">Content</ul>)

      result = ContentTag.list("Content", class: "extra")

      assert_safe(result, expected)
    end

    test "defines name/2 block function clause for given component" do
      expected = ~s(<ul class="list extra">Content</ul>)

      result =
        ContentTag.list class: "extra" do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "defines variant/2 function for given component" do
      expected = ~s(<ul class="list list-flush">Content</ul>)

      result = ContentTag.list(:flush, "Content")

      assert_safe(result, expected)
    end

    test "defines variant/2 block function for given component" do
      expected = ~s(<ul class="list list-flush">Content</ul>)

      result =
        ContentTag.list :flush do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "defines variant/3 function clause for given component" do
      expected = ~s(<ul class="list list-flush extra">Content</ul>)

      result = ContentTag.list(:flush, "Content", class: "extra")

      assert_safe(result, expected)
    end

    test "defines variant/3 block function clause for given component" do
      expected = ~s(<ul class="list list-flush extra">Content</ul>)

      result =
        ContentTag.list :flush, class: "extra" do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts an atom tag option" do
      expected = ~s(<div class="list">Content</div>)

      result =
        ContentTag.list tag: :div do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts an anonymous function tag option" do
      expected = ~s(<a class="list" href="#">Link</a>)

      result =
        ContentTag.list tag: &Phoenix.HTML.Link.link/2, to: "#" do
          "Link"
        end

      assert_safe(result, expected)
    end
  end

  describe "prepend and append options" do
    defmodule Prepend do
      import ExComponent

      defcontenttag(:list, tag: :ul, class: "list")
    end

    test "accepts a `{:tag, opts}` prepend option" do
      expected = ~s(<ul class="list"><hr class="extra">Content</ul>)

      result =
        Prepend.list prepend: {:hr, [class: "extra"]} do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts a `{:tag, \"content\"}` prepend option" do
      expected = ~s(<ul class="list"><button>&amp;times;</button>Content</ul>)

      result =
        Prepend.list prepend: {:button, "&times;"} do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts a `{:tag, \"content\", opts}` prepend option" do
      expected = ~s(<ul class="list"><button class="extra">&amp;times;</button>Content</ul>)

      result =
        Prepend.list prepend: {:button, "&times;", class: "extra"} do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts a {:safe, iodata} prepend option" do
      expected = ~s(<ul class="list"><button class="close">&amp;times;</button>Content</ul>)

      close_button = Phoenix.HTML.Tag.content_tag(:button, "&times;", class: "close")

      result =
        Prepend.list prepend: close_button do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts an append option" do
      expected = ~s(<ul class="list">Content<hr></ul>)

      result =
        Prepend.list append: {:hr, []} do
          "Content"
        end

      assert_safe(result, expected)
    end
  end

  describe "parent option" do
    defmodule Parent do
      import ExComponent

      defcontenttag(:list, tag: :ul, class: "list")
    end

    test "accepts an atom parent option" do
      expected = ~s(<div><ul class="list">Content</ul></div>)

      result =
        Parent.list parent: :div do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts a tuple parent option" do
      expected = ~s(<div><ul class="list">Content</ul></div>)

      result =
        Parent.list parent: {:div, []} do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts an anonymous function parent option" do
      expected = ~s(<div><ul class="list">Content</ul></div>)

      result =
        Parent.list parent: &Phoenix.HTML.Tag.content_tag(:div, &1) do
          "Content"
        end

      assert_safe(result, expected)
    end

    test "accepts a `:wrap_content` option" do
      expected = ~s(<button class="list close"><span>&amp;times;</span></button>)

      result =
        Parent.list tag: :button, wrap_content: :span, class: "close" do
          "&times;"
        end

      assert_safe(result, expected)
    end
  end

  describe "variant option" do
    defmodule Alert do
      import ExComponent

      defcontenttag(:alert,
        tag: :div,
        class: "alert",
        variants: [
          primary: [class: "primary"],
          success: [class: "success"],
          another: [class: "another", merge: false],
          onemore: [class: "onemore", prefix: false],
          andmore: [class: "andmore", prefix: "custom"]
        ]
      )

      defcontenttag(:col,
        tag: :div,
        class: "col",
        variants:
          for col <- 1..12 do
            {:"#{col}", [class: col, merge: false]}
          end,

        options: [
          sm: [class: "col-sm"],
          md: [class: "col-md"],
          lg: [class: "col-lg"]
        ]
      )
    end

    test "when atom" do
      expected = ~s(<div class="alert alert-success">Alert!</div>)

      result =
        Alert.alert :success do
          "Alert!"
        end

      assert_safe result, expected
    end

    test "when list" do
      expected = ~s(<div class="alert alert-success alert-primary">Alert!</div>)

      result =
        Alert.alert variants: [:success, :primary] do
          "Alert!"
        end

      assert_safe result, expected
    end

    test "when variant `:merge` is `false`" do
      expected = ~s(<div class="alert-another">Alert!</div>)

      result =
        Alert.alert :another do
          "Alert!"
        end

      assert_safe result, expected
    end

    test "when variant `:prefix` is `false`" do
      expected = ~s(<div class="alert onemore">Alert!</div>)

      result =
        Alert.alert :onemore do
          "Alert!"
        end

      assert_safe(result, expected)
    end

    test "when variant `:prefix` is custom" do
      expected = ~s(<div class="alert custom-andmore">Alert!</div>)

      result =
        Alert.alert :andmore do
          "Alert!"
        end

      assert_safe(result, expected)
    end

    test "with `:class` option" do
      expected = ~s(<div class="alert alert-success extra">Alert!</div>)

      result =
        Alert.alert :success, class: "extra" do
          "Alert!"
        end

      assert_safe(result, expected)
    end

    test "col with integer variant" do
      expected = ~s(<div class="col-1">Column!</div>)

      result =
        Alert.col 1 do
          "Column!"
        end

      assert_safe(result, expected)
    end

    test "col with kitchen sink" do
      expected = ~s(<div class="col-6 col-sm-12 col-md-6 extra">Column!</div>)

      result =
        Alert.col 6, sm: 12, md: 6, class: "extra" do
          "Column!"
        end

      assert_safe(result, expected)
    end
  end

  describe "options" do
    defmodule Options do
      import ExComponent

      defcontenttag(:col, tag: :div, class: "col", options: [
          sm: [class: "col-sm"],
          md: [class: "md", prefix: true],
          lg: [class: "lg", prefix: "custom"],
          auto: [class: "auto"]
        ]
      )
    end

    test "registers options" do
      expected = ~s(<div class="col col-sm-6">Column!</div>)

      result =
        Options.col sm: 6 do
          "Column!"
        end

      assert_safe(result, expected)
    end

    test "accepts a boolean `:prefix`" do
      expected = ~s(<div class="col col-md-6">Column!</div>)

      result =
        Options.col md: 6 do
          "Column!"
        end

      assert_safe(result, expected)
    end

    test "accepts a custom `:prefix`" do
      expected = ~s(<div class="col custom-lg-6">Column!</div>)

      result =
        Options.col lg: 6 do
          "Column!"
        end

      assert_safe(result, expected)
    end

    test "with a boolean value" do
      expected = ~s(<div class="col auto">Column!</div>)

      result =
        Options.col auto: true do
          "Column!"
        end

      assert_safe(result, expected)
    end
  end
end
