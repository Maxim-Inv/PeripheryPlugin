# [Periphery](https://github.com/peripheryapp/periphery) SPM plugin proof of concept

This package contains two plugins and one executable target:
1. **PeripheryPlugin** - command plugin (this means you need to run it manually from XCode or the command line) - runs a `peripheral scan` for selected targets and stores the results in the plugin's working directory. Please note - you must first build the targets before running this command. You can also view the results in the Xcode Report Navigator tab.
2. **PeripheryRendererPlugin** (Optional) - buildTool plugin (need to attach this plugin to the `target.plugins` section in `Package.swift`) - displays results from `PeripheryPlugin` in the Xcode Issue Navigator tab. Need to build targets again.
3. **PeripheryRenderer** - executable target used by `PeripheryRendererPlugin`, simply prints the result from `PeripheryPlugin`.
