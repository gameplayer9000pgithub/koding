class NFinderContextMenuController extends KDController

  ###
  CONTEXT MENU CREATION
  ###

  getMenuItems:(fileViews)->

    if fileViews.length > 1
      @getMutilpleItemMenu fileViews
    else
      [fileView] = fileViews
      switch fileView.getData().type
        when "vm"         then @getVmMenu fileView
        when "file"       then @getFileMenu fileView
        when "folder"     then @getFolderMenu fileView
        when "mount"      then @getMountMenu fileView
        when "brokenLink" then @getBrokenLinkMenu fileView
        # when "section" then @getSectionMenu fileData

  getContextMenu:(fileViews, event)->

    @contextMenu.destroy() if @contextMenu
    items = @getMenuItems fileViews
    [fileView] = fileViews
    if items
      @contextMenu = new JContextMenu
        event    : event
        delegate : fileView
        cssClass : 'finder'
      , items
      @contextMenu.on "ContextMenuItemReceivedClick", (contextMenuItem)=>
        @handleContextMenuClick fileView, contextMenuItem
      return @contextMenu
    else
      return no

  destroyContextMenu:->
    @contextMenu.destroy()

  handleContextMenuClick:(fileView, contextMenuItem)->

    @emit 'ContextMenuItemClicked', {fileView, contextMenuItem}

  getFileMenu:(fileView)->

    fileData = fileView.getData()

    items =
      'Open File'                 :
        separator                 : yes
        action                    : 'openFile'
      # 'Open with...'              :
      #   children                  : @getOpenWithMenuItems fileView
      Delete                      :
        action                    : 'delete'
        separator                 : yes
      Rename                      :
        action                    : 'rename'
      Duplicate                   :
        action                    : 'duplicate'
      'Set permissions'           :
        children                  :
          customView              : new NSetPermissionsView {}, fileData
      Extract                     :
        action                    : 'extract'
      Compress                    :
        children                  :
          'as .zip'               :
            action                : 'zip'
          'as .tar.gz'            :
            action                : 'tarball'
      Download                    :
        separator                 : yes
        action                    : 'download'
        disabled                  : yes
      'Public URL...'             :
        separator                 : yes
      'New File'                  :
        action                    : 'createFile'
      'New Folder'                :
        action                    : 'createFolder'
      'Upload to Dropbox'         :
        action                    : 'dropboxSaver'

    if 'archive' isnt FSItem.getFileType FSItem.getFileExtension fileData.name
      delete items.Extract
    else
      delete items.Compress

    unless FSHelper.isPublicPath fileData.path
      delete items['Public URL...']
    else
      items['Public URL...'].children =
        customView : new NCopyUrlView {}, fileData

    return items


  getFolderMenu:(fileView)->

    fileData = fileView.getData()

    items =
      Expand                      :
        action                    : "expand"
        separator                 : yes
      Collapse                    :
        action                    : "collapse"
        separator                 : yes
      'Make this top Folder'      :
        action                    : 'makeTopFolder'
        separator                 : yes
      Delete                      :
        action                    : 'delete'
        separator                 : yes
      Rename                      :
        action                    : 'rename'
      Duplicate                   :
        action                    : 'duplicate'
      Compress                    :
        children                  :
          'as .zip'               :
            action                : 'zip'
          'as .tar.gz'            :
            action                : 'tarball'
      'Set permissions'           :
        separator                 : yes
        children                  :
          customView              : new NSetPermissionsView {}, fileData
      'New File'                  :
        action                    : 'createFile'
      'New Folder'                :
        action                    : 'createFolder'
      'Upload file...'            :
        action                    : 'upload'
      'Clone a repo here'         :
        action                    : "cloneRepo"
      Download                    :
        disabled                  : yes
        action                    : "download"
        separator                 : yes
      Dropbox                     :
        children                  :
          'Download from Dropbox' :
            action                : 'dropboxChooser'
          'Upload to Dropbox'     :
            action                : 'dropboxSaver'
        separator                 : yes
      'Public URL...'             :
        separator                 : yes
      Refresh                     :
        action                    : 'refresh'

    if fileView.expanded
      delete items.Expand
    else
      delete items.Collapse

    unless FSHelper.isPublicPath fileData.path
      delete items['Public URL...']
    else
      items['Public URL...'].children =
        customView : new NCopyUrlView {}, fileData

    {nickname} = KD.whoami().profile

    if fileData.path is "/home/#{nickname}/Applications"
      items.Refresh.separator         = yes
      items["Make a new Application"] =
        action : "makeNewApp"


    if fileData.getExtension() is "kdapp"
      items.Refresh.separator   = yes
      items['Application menu'] =
        children                  :
          Compile                 :
            action                : "compile"
          Run                     :
            action                : "runApp"
            separator             : yes
          "Download source files" :
            action                : "downloadApp"

      if KD.checkFlag('app-publisher') or KD.checkFlag('super-admin')
        items['Application menu'].children["Download source files"].separator = yes
        items['Application menu'].children["Publish to App Catalog"] =
          action : "publish"

    return items

  getBrokenLinkMenu:(fileView)->

    fileData   = fileView.getData()
    items      =
      Delete   :
        action : 'delete'

    items

  getVmMenu:(fileView)->

    fileData = fileView.getData()

    items =
      Refresh                     :
        action                    : 'refresh'
        separator                 : yes
      'Unmount VM'                :
        action                    : 'unmountVm'
      'Open VM Terminal'          :
        action                    : 'openVmTerminal'
        separator                 : yes
      Expand                      :
        action                    : 'expand'
        separator                 : yes
      Collapse                    :
        action                    : 'collapse'
        separator                 : yes
      'Hide Invisible Files'      :
        action                    : 'hideDotFiles'
        separator                 : yes
      'Show Invisible Files'      :
        action                    : 'showDotFiles'
        separator                 : yes
      'New File'                  :
        action                    : 'createFile'
      'New Folder'                :
        action                    : 'createFolder'
      'Upload file...'            :
        action                    : 'upload'

    if fileView.expanded
      delete items.Expand
    else
      delete items.Collapse

    fc = KD.getSingleton 'finderController'
    if fc.isNodesHiddenFor fileData.vmName
      delete items['Hide Invisible Files']
    else
      delete items['Show Invisible Files']

    return items

  getMountMenu:(fileView)->

    fileData = fileView.getData()

    items =
      Refresh                     :
        action                    : 'refresh'
        separator                 : yes
      Expand                      :
        action                    : "expand"
        separator                 : yes
      Collapse                    :
        action                    : "collapse"
        separator                 : yes
      'New File'                  :
        action                    : 'createFile'
      'New Folder'                :
        action                    : 'createFolder'
      'Upload file...'            :
        action                    : 'upload'

    if fileView.expanded
      delete items.Expand
    else
      delete items.Collapse

    return items

  getMutilpleItemMenu:(fileViews)->

    types =
      file    : no
      folder  : no
      mount   : no

    for fileView in fileViews
      types[fileView.getData().type] = yes

    if types.file and not types.folder and not types.mount
      return @getMultipleFileMenu fileViews

    else if not types.file and types.folder and not types.mount
      return @getMultipleFolderMenu fileViews

    items =

      Delete                      :
        action                    : 'delete'
        separator                 : yes
      Duplicate                   :
        action                    : 'duplicate'
      Compress                    :
        children                  :
          'as .zip'               :
            action                : 'zip'
          'as .tar.gz'            :
            action                : 'tarball'
      Download                    :
        disabled                  : yes
        action                    : 'download'

    return items

  getMultipleFolderMenu:(folderViews)->

    items =
      Expand            :
        action          : "expand"
        separator       : yes
      Collapse          :
        action          : "collapse"
        separator       : yes
      Delete            :
        action          : 'delete'
        separator       : yes
      Duplicate         :
        action          : 'duplicate'
      'Set permissions' :
        children        :
          customView    : (new NSetPermissionsView {},{mode : "000", type : "multiple"})
      Compress          :
        children        :
          'as .zip'     :
            action      : 'zip'
          'as .tar.gz'  :
            action      : 'tarball'
      Download          :
        disabled        : yes
        action          : 'download'

    multipleText = "Delete #{folderViews.length} folders"
    items.Delete = items[multipleText] =
      action    : 'delete'

    allCollapsed = allExpanded = yes
    for folderView in folderViews
      if folderView.expanded then allCollapsed = no
      else allExpanded = no

    delete items.Collapse if allCollapsed
    delete items.Expand if allExpanded

    return items

  getMultipleFileMenu:(fileViews)->

    items =
      'Open Files'      :
        action          : 'openFile'
      Delete            :
        action          : 'delete'
        separator       : yes
      Duplicate         :
        action          : 'duplicate'
      'Set permissions' :
        children        :
          customView    : (new NSetPermissionsView {}, {mode : "000"})
      Compress          :
        separator       : yes
        children        :
          'as .zip'     :
            action      : 'zip'
          'as .tar.gz'  :
            action      : 'tarball'
      Download          :
        disabled        : yes
        action          : 'download'

    multipleText = "Delete #{fileViews.length} files"
    items.Delete = items[multipleText] =
      action    : 'delete'

    return items

  getOpenWithMenuItems: (fileView) ->
    items            = {}
    reWebHome        = ///
      ^/home/#{KD.nick()}/Web/
    ///
    {path}           = fileView.getData()
    plainPath        = FSHelper.plainPath path
    fileExtension    = FSItem.getFileExtension path

    # FIXME: Add this ability later ~ GG
    # appsController   = @getSingleton "kodingAppsController"
    # {extensionToApp} = appsController
    # possibleApps     = (extensionToApp[fileExtension] or extensionToApp.txt) or []
    # for appName in possibleApps
    #   items[appName] = action: "openFileWithApp"

    items["Viewer"]               = action   : "previewFile"  if plainPath.match reWebHome
    items["separator"]            = type     : "separator"
    items["Other Apps"]           = action   : "showOpenWithModal", separator : yes
    items["Search the App Store"] = disabled : yes
    items["Contribute an Editor"] = disabled : yes

    return items
  # getOpenWithMenuItems: (fileView) ->
  #   items            = {}
  #   reWebHome        = ///
  #     ^/home/#{KD.nick()}/Web/
  #   ///
  #   {path}           = fileView.getData()
  #   plainPath        = FSHelper.plainPath path
  #   fileExtension    = FSItem.getFileExtension path
  #   appsController   = @getSingleton "kodingAppsController"
  #   {extensionToApp} = appsController
  #   possibleApps     = (extensionToApp[fileExtension] or extensionToApp.txt) or []
  #   for appName in possibleApps
  #     items[appName] = action: "openFileWithApp"

  #   items["Viewer"]               = action   : "previewFile"  if plainPath.match reWebHome
  #   items["separator"]            = type     : "separator"
  #   items["Other Apps"]           = action   : "showOpenWithModal", separator : yes
  #   items["Search the App Store"] = disabled : yes
  #   items["Contribute an Editor"] = disabled : yes

  #   return items

# this is shorter but needs coffee script update

# 'Open File'                 : action : 'openFile'
# 'Open with...'              :
#   children                  :
#     'Ace Editor'            : action : 'openFile'
#     'CodeMirror'            : action : 'openFileWithCodeMirror'
#     'Viewer'                : action : 'previewFile'
#     divider                 : yes
#     'Search the App Store'  : disabled : yes
#     'Contribute an Editor'  : disabled : yes
# divider                     : yes
# Delete                      : action : 'delete'
# divider                     : yes
# Rename                      : action : 'rename'
# Duplicate                   : action : 'duplicate'
# 'Set permissions'           :
#   children                  :
#     customView              : KDView
# Extract                     : action : 'extract'
# Compress                    :
#   children                  :
#     'as .zip'               :
#       action                : 'zip'
#     'as .tar.gz'            :
#       action                : 'tarball'
# Download                    : action : 'download'
# divider                     : yes
# 'New File'                  : action : 'createFile'
# 'New Folder'                : action : 'createFolder'
# 'Upload file...'            : action : 'upload', disabled : yes
# 'Clone from Github...'      : action : 'gitHubClone', disabled : yes
