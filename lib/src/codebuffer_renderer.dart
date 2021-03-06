import 'dart:convert';
import 'package:jclosure/structs/symbols/symbol_table/SymbolTable.dart';
import 'package:code_buffer/code_buffer.dart';
import 'ast/ast.dart';
import 'member_resolver.dart';
import 'renderer.dart';

/** Concrete renderer class which renders document as HTML to a CodeBuffer */

class CodeBufferRenderer extends Renderer<CodeBuffer>
{
  const CodeBufferRenderer();

  /** Renders a real element */
  @override
  void renderPrimaryElement(Element element, CodeBuffer output, IMemberResolver memberResolver, SymbolTable scope, SymbolTable childScope, bool html5)
  {
    output..write('<')..write(element.tagName.name);

    for (Attribute attribute in element.attributes)
    {
      dynamic value = attribute.value?.compute(memberResolver, childScope);

      if (value == false || value == null) continue;

      output.write(' ${attribute.name}');

      if (value == true) {
        continue;
      } else {
        output.write('="');
      }

      String msg;

      if (value is Iterable) {
        msg = value.join(' ');
      }
      else if (value is Map) {
        msg = value.keys.fold<StringBuffer>(StringBuffer(), (StringBuffer buf, dynamic k) {
          dynamic v = value[k];
          if (v == null) return buf;
          return buf..write('$k: $v;');
        }).toString();
      }
      else {
        msg = value.toString();
      }

      output.write(attribute.isRaw ? msg : htmlEscape.convert(msg));
      output.write('"');
    }

    if (element is SelfClosingElement) {
      if (html5) {
        output.writeln('>');
      }
      else {
        output.writeln('/>');
      }
    }
    else {
      output.writeln('>');
      output.indent();

      renderElementChildren(element, output, memberResolver, childScope, html5);

      renderElementClose(output, element);
    }
  }

  /** Abstract method. Write a text literal from the template source */
  @override
  void writeTextLiteral(CodeBuffer output, String? text)
  {
    output.write(text);
  }

  /** Write an interpolated value, properly escaping */
  @override
  void writeInterpolatedValue(CodeBuffer output, Interpolation interpolation, dynamic value)
  {
    if (interpolation.isRaw) {
      output.write(value);
    }
    else {
      output.write( htmlEscape.convert( value.toString() ) );
    }
  }

  /** Render element close */
  @override
  void renderElementClose(CodeBuffer output, Element element)
  {
    output.writeln();
    output.outdent();
    output.writeln('</${element.tagName.name}>');
  }

  /** Called before render of child element */
  @override
  void beforeRenderChildElement(CodeBuffer output)
  {
    if (output.lastLine?.text.isNotEmpty == true) {
      output.writeln();
    }
  }
}
