{fontFamily}: {
  diffEditor = {
    renderSideBySide = true;
  };
  editor = {
    acceptSuggestionOnEnter = "on";
    accessibilitySupport = "off";
    detectIndentation = true;
    find.seedSearchStringFromSelection = "always";
    fontFamily = fontFamily;
    fontLigatures = false;
    fontSize = 13;
    formatOnSave = true;
    formatOnPaste = false;
    formatOnType = false;
    guides.indentation = true;
    insertSpaces = true;
    minimap.enabled = true;
    minimap.renderCharacters = false;
    multiCursorModifier = "ctrlCmd";
    renderIndentGuides = true;
    renderWhitespace = "boundary";
    rulers = [120];
    scrollBeyondLastLine = true;
    showFoldingControls = "never";
    snippetSuggestions = "bottom";
    suggestSelection = "first";
    wordSeparators = "./\\()\"'-:,.;<>~-!@#$%^&*|+=[]{}`~?";
    wordWrap = "on";
    inlineSuggest.enabled = true;
    semanticHighlighting.enabled = true;
  };
  emmet = {
    showSuggestionsAsSnippets = false;
    showExpandedAbbreviation = "never";
  };
  explorer = {
    confirmDelete = false;
    confirmDragAndDrop = false;
  };
  files = {
    associations = {
      "*.jinja" = "jinja";
      "*.pyi" = "python";
      "*.rst.inc" = "restructuredtext";
      ".zshrc_local" = "shellscript";
      "*.py" = "python";
    };
    autoSave = "afterDelay";
    autoSaveDelay = 1000;
    insertFinalNewline = true;
    trimTrailingWhitespace = true;
  };
  # gitlens = {
  #   codeLens.enabled = false;
  #   blame.highlight.enabled = false;
  # };
  # javascript = {
  #   updateImportsOnFileMove.enabled = "always";
  # };
  liveshare = {
    featureSet = "stable";
  };
  python = {
    languageServer = "Pylance";
    showStartPage = false;
  };
  # "[python]" = {
  #   editor.formatOnType = false;
  # };
  # "[nix]" = {
  #   editor = {
  #     formatOnType = false;
  #     formatOnSave = true;
  #   };
  # };
  security = {
    workspace.trust.untrustedFiles = "prompt";
  };
  search.exclude = {
    "**/.vscode/**" = true;
  };
  terminal = {
    # integrated.fontFamily = fontFamily;
    integrated.minimumContrastRatio = 1;
  };
  todohighlight = {
    isEnable = true;
    include = [
      "**/*.json"
      "**/*.js"
      "**/*.jsx"
      "**/*.ts"
      "**/*.tsx"
      "**/*.html"
      "**/*.py"
      "**/*.css"
      "**/*.scss"
    ];
    keywords = [
      "TODO"
      "FIXME"
    ];
  };
  # typescript = {
  #   updateImportsOnFileMove.enabled = "never";
  #   preferences.useAliasesForRenames = false;
  # };
  window = {
    titleBarStyle = "custom";
    zoomLevel = 1;
    # title = "\${dirty}\${activeEditorLong} - \${rootName}";
    # openFilesInNewWindow = "off";
    # closeWhenEmpty = false;
  };
  workbench = {
    colorTheme = "Catppuccin Latte";
    iconTheme = "catppuccin-latte";
    settings.editor = "json";
    editorAssociations = {
      "*.ipynb" = "jupyter-notebook";
    };
  };
  "[javascript]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[json]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[typescript]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[typescriptreact]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[astro]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[python]" = {
    "editor.defaultFormatter" = "ms-python.black-formatter";
  };
  "prettier.documentSelectors" = ["**/*.astro"];
  "github.copilot.enable" = {
    "*" = true;
  };
  "git.autofetch" = false;
  "telemetry.telemetryLevel" = "off";
  "update.showReleaseNotes" = false;
}
