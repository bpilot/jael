import 'package:symbol_table/symbol_table.dart';
import "member_resolver.dart";
import "ast/ast.dart";
import "parse_document.dart";
import "renderer.dart";

/** @fileoverview Manages static renderer state */

typedef String _FileReadCallbackStrategy(String fileName);

class RendererManager<T extends StringSink> {
  // Renderer
  final Renderer<T> _renderer;

  // State
  String _basePath = "";

  /** May or may not be reading an actual file. Could be looking up from a map. */
  _FileReadCallbackStrategy _fileReadStrategy;

  IMemberResolver _memberResolver;

  // Cache
  Map<String, Document> _documentCache = <String, Document>{};

  RendererManager(Renderer<T> this._renderer);

  /** Do not use user input to determine base path */
  void setBasePath(String basePath)
  {
    if ( basePath.isNotEmpty && !basePath.endsWith("/") ) {
      throw new Exception("Base path must end with trialing /");
    }
    _basePath = basePath;
  }

  /** Sets file read strategy */
  void setFileReadStrategy(_FileReadCallbackStrategy fileReadStrategy)
  {
    _fileReadStrategy = fileReadStrategy;
  }

  /** Sets to read from a map. Uses closure to hold reference to map */
  void setFileMap(Map<String, String> fileMap)
  {
    setFileReadStrategy(
      (String fileName) => fileMap.containsKey(fileName) ? fileMap[fileName] : throw new Exception("No such fileName in fileMap.")
    );
  }

  /** Set member resolver */
  void setMemberResolver(IMemberResolver memberResolver)
  {
    _memberResolver = memberResolver;
  }

  /** Clear cache */
  void clearCache()
  {
    _documentCache.clear();
  }

  /** Render from file (may not be an actual file) */
  void renderFile(T output, String fileName, SymbolTable<dynamic> symbolTable)
  {
    Document document = _getDocumentCached(fileName);

    _renderer.render(
      document,
      output,
      symbolTable,
      memberResolver: _memberResolver);
  }

  Document _getDocumentCached(String fileName)
  {
    if ( !_documentCache.containsKey(fileName) ) {
      print("Jael RendererManager cache miss: ${fileName}");
      _documentCache[fileName] = _getDocument(fileName);
    }
    return _documentCache[fileName];
  }

  Document _getDocument(String fileName)
  {
    String templateText = _fileReadStrategy( _getFullPath(fileName) );
    return parseDocument(templateText);
  }

  /** Get full path */
  String _getFullPath(String fileName)
  {
    if ( fileName.contains("..") ) {
      throw new Exception();
    }

    return _basePath + fileName;
  }
}
