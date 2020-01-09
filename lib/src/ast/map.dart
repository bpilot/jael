import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:jael/src/member_resolver.dart';
import 'ast_node.dart';
import 'expression.dart';
import 'identifier.dart';
import 'token.dart';

class MapLiteral extends Literal {
  final Token lCurly, rCurly;
  final List<KeyValuePair> pairs;

  MapLiteral(this.lCurly, this.pairs, this.rCurly);

  @override
  dynamic compute(IMemberResolver memberResolver, SymbolTable scope) {
    return pairs.fold<Map>({}, (out, p) {
      var key, value;

      if (p.colon == null) {
        if (p.key is! Identifier) {
          key = value = p.key.compute(memberResolver, scope);
        } else {
          key = (p.key as Identifier).name;
          value = p.key.compute(memberResolver, scope);
        }
      } else {
        key = p.key.compute(memberResolver, scope);
        value = p.value.compute(memberResolver, scope);
      }

      return out..[key] = value;
    });
  }

  @override
  FileSpan get span {
    return pairs
        .fold<FileSpan>(lCurly.span, (out, p) => out.expand(p.span))
        .expand(rCurly.span);
  }
}

class KeyValuePair extends AstNode {
  final Expression key, value;
  final Token colon;

  KeyValuePair(this.key, this.colon, this.value);

  @override
  FileSpan get span {
    if (colon == null) return key.span;
    return colon.span.expand(colon.span).expand(value.span);
  }
}
