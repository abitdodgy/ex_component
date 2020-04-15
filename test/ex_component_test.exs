defmodule ExComponentTest do
  use ExUnit.Case

  import Phoenix.HTML, only: [safe_to_string: 1]

  defmodule List do
    import ExComponent

    defcomp(:list, type: {:content_tag, :ul}, class: "list", variants: [:flush, :horizontal])
  end

  describe "defcomp with `:content_tag`" do
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

      result =
        Delegate.link to: "#" do
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

      defcomp(:close_button, type: {:content_tag, :button}, class: "close")

      defcomp(:alert_with_prepend_func,
        type: {:content_tag, :div},
        class: "alert",
        prepend: {&Siblings.close_button/1, "&nbsp;"},
        variants: [:success]
      )

      defcomp(:alert_with_prepend_func_and_opts,
        type: {:content_tag, :div},
        class: "alert",
        prepend: {&Siblings.close_button/2, "&nbsp;", class: "extra"},
        variants: [:success]
      )

      defcomp(:alert_with_prepend_atom,
        type: {:content_tag, :div},
        class: "alert",
        prepend: {:button, "&nbsp;"},
        variants: [:success]
      )

      defcomp(:alert_with_prepend_atom_and_opts,
        type: {:content_tag, :div},
        class: "alert",
        prepend: {:button, "&nbsp;", class: "extra"},
        variants: [:success]
      )
    end

    test "with `:append` option appends given tag" do
      expected = ~s(<div class=\"alert alert-success\">Alert!<hr></div>)

      result = Siblings.alert_with_append(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:prepend` option prepends given tag" do
      expected = ~s(<div class=\"alert alert-success\"><hr>Alert!</div>)

      result = Siblings.alert_with_prepend(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:append` and `:prepend` options appends and prepends given tags" do
      expected = ~s(<div class=\"alert alert-success\"><hr>Alert!<hr></div>)

      result = Siblings.alert_with_prepend_and_append(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "overrides `:append` option with function opts" do
      expected = ~s(<div class=\"alert alert-success\">Alert!<br></div>)

      result = Siblings.alert_with_append(:success, "Alert!", append: :br)

      assert safe_to_string(result) == expected
    end

    test "overrides `:prepend` option with function opts" do
      expected = ~s(<div class=\"alert alert-success\"><br>Alert!</div>)

      result = Siblings.alert_with_prepend(:success, "Alert!", prepend: :br)

      assert safe_to_string(result) == expected
    end

    test "overrides `:append` and `:prepend` options with function opts" do
      expected = ~s(<div class=\"alert alert-success\"><br>Alert!<br></div>)

      result = Siblings.alert_with_prepend(:success, "Alert!", append: :br, prepend: :br)

      assert safe_to_string(result) == expected
    end

    test "with `:prepend` option as a function" do
      expected =
        ~s(<div class=\"alert alert-success\"><button class=\"close\">&amp;nbsp;</button>Alert!</div>)

      result = Siblings.alert_with_prepend_func(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:prepend` option as a function and opts" do
      expected =
        ~s(<div class=\"alert alert-success\"><button class=\"close extra\">&amp;nbsp;</button>Alert!</div>)

      result = Siblings.alert_with_prepend_func_and_opts(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:prepend` option as an atom" do
      expected = ~s(<div class=\"alert alert-success\"><button>&amp;nbsp;</button>Alert!</div>)

      result = Siblings.alert_with_prepend_atom(:success, "Alert!")

      assert safe_to_string(result) == expected
    end

    test "with `:prepend` option as an atom and opts" do
      expected =
        ~s(<div class=\"alert alert-success\"><button class=\"extra\">&amp;nbsp;</button>Alert!</div>)

      result = Siblings.alert_with_prepend_atom_and_opts(:success, "Alert!")

      assert safe_to_string(result) == expected
    end
  end

  test "defcomp with `:tag` opt overrides default tag" do
    expected = ~s(<ol class=\"list\">Content</ol>)

    result = List.list("Content", tag: :ol)

    assert safe_to_string(result) == expected
  end

  describe "defcomp with parent option" do
    defmodule Parent do
      import ExComponent

      defcomp(:parent_tag, type: {:content_tag, :ol}, class: "breadcrumb", parent: :nav)

      defcomp(:parent_tag_opts,
        type: {:content_tag, :ol},
        class: "breadcrumb",
        parent: {:nav, [role: "nav"]}
      )

      defcomp(:nav, type: {:content_tag, :nav}, class: "nav", html_opts: [role: "nav"])

      defcomp(:parent_fun, type: {:content_tag, :ol}, class: "breadcrumb", parent: &Parent.nav/2)

      defcomp(:parent_fun_opts,
        type: {:content_tag, :ol},
        class: "breadcrumb",
        parent: {&Parent.nav/2, [role: "parent"]}
      )
    end

    test "nests the component in the given tag" do
      expected = ~s(<nav><ol class=\"breadcrumb\">Content</ol></nav>)

      result = Parent.parent_tag("Content")

      assert safe_to_string(result) == expected
    end

    test "nests the component in the given tag with opts" do
      expected = ~s(<nav role="nav"><ol class=\"breadcrumb\">Content</ol></nav>)

      result = Parent.parent_tag_opts("Content")

      assert safe_to_string(result) == expected
    end

    test "nests the component in the given function" do
      expected = ~s(<nav class="nav" role="nav"><ol class=\"breadcrumb\">Content</ol></nav>)

      result = Parent.parent_fun("Content")

      assert safe_to_string(result) == expected
    end

    test "nests the component in the given function and opts" do
      expected = ~s(<nav class="nav" role="parent"><ol class=\"breadcrumb\">Content</ol></nav>)

      result = Parent.parent_fun_opts("Content")

      assert safe_to_string(result) == expected
    end
  end

  test "with `:delegate` opt"
  test "variants with an underscore"
end
