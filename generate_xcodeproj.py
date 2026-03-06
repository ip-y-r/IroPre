#!/usr/bin/env python3
"""
IroPre Xcode project generator.
Generates IroPre.xcodeproj/project.pbxproj without XcodeGen.
"""
import uuid
import os

def new_id():
    """Generate a 24-char Xcode-style UUID."""
    return uuid.uuid4().hex[:24].upper()

# ── UUIDs ────────────────────────────────────────────────────────────────────
# Project / Config
PROJECT_ID          = new_id()
MAIN_GROUP_ID       = new_id()
PRODUCTS_GROUP_ID   = new_id()

APP_TARGET_ID       = new_id()
TEST_TARGET_ID      = new_id()

APP_PRODUCT_REF     = new_id()
TEST_PRODUCT_REF    = new_id()

APP_DEBUG_CONFIG_ID  = new_id()
APP_RELEASE_CONFIG_ID= new_id()
TEST_DEBUG_CONFIG_ID = new_id()
TEST_RELEASE_CONFIG_ID=new_id()
PROJ_DEBUG_CONFIG_ID = new_id()
PROJ_RELEASE_CONFIG_ID=new_id()

APP_CONFIG_LIST_ID  = new_id()
TEST_CONFIG_LIST_ID = new_id()
PROJ_CONFIG_LIST_ID = new_id()

APP_SOURCES_PHASE   = new_id()
APP_RESOURCES_PHASE = new_id()
APP_FRAMEWORKS_PHASE= new_id()
TEST_SOURCES_PHASE  = new_id()
TEST_FRAMEWORKS_PHASE=new_id()

# Source files: (group_name, path_from_IroPre, filename)
SOURCE_FILES = [
    # App
    ("App",                    "App",                    "IroPreApp.swift"),
    ("App",                    "App",                    "ContentView.swift"),
    # Core/Models
    ("Models",                 "Core/Models",            "Cell.swift"),
    ("Models",                 "Core/Models",            "Move.swift"),
    ("Models",                 "Core/Models",            "Puzzle.swift"),
    ("Models",                 "Core/Models",            "GameState.swift"),
    ("Models",                 "Core/Models",            "Achievement.swift"),
    # Core/Engine
    ("Engine",                 "Core/Engine",            "PuzzleGenerator.swift"),
    ("Engine",                 "Core/Engine",            "PuzzleValidator.swift"),
    ("Engine",                 "Core/Engine",            "HintEngine.swift"),
    # Core/Theme
    ("Theme",                  "Core/Theme",             "ColorPalette.swift"),
    ("Theme",                  "Core/Theme",             "AccessibilityMode.swift"),
    ("Theme",                  "Core/Theme",             "FontManager.swift"),
    # Features/Home
    ("Home",                   "Features/Home",          "HomeView.swift"),
    ("Home",                   "Features/Home",          "HomeViewModel.swift"),
    # Features/Game
    ("Game",                   "Features/Game",          "GameView.swift"),
    ("Game",                   "Features/Game",          "GameViewModel.swift"),
    ("Game",                   "Features/Game",          "BoardView.swift"),
    ("Game",                   "Features/Game",          "PaletteView.swift"),
    ("Game",                   "Features/Game",          "PauseOverlayView.swift"),
    # Features/LevelSelect
    ("LevelSelect",            "Features/LevelSelect",   "LevelSelectView.swift"),
    ("LevelSelect",            "Features/LevelSelect",   "LevelSelectViewModel.swift"),
    # Features/Tutorial
    ("Tutorial",               "Features/Tutorial",      "TutorialView.swift"),
    ("Tutorial",               "Features/Tutorial",      "TutorialViewModel.swift"),
    # Features/Achievements
    ("Achievements",           "Features/Achievements",  "AchievementsView.swift"),
    ("Achievements",           "Features/Achievements",  "AchievementsViewModel.swift"),
    # Features/Settings
    ("Settings",               "Features/Settings",      "SettingsView.swift"),
    ("Settings",               "Features/Settings",      "SettingsViewModel.swift"),
    # Data/Storage
    ("Storage",                "Data/Storage",           "GameProgress.swift"),
    ("Storage",                "Data/Storage",           "ClearRecord.swift"),
    ("Storage",                "Data/Storage",           "AchievementRecord.swift"),
    ("Storage",                "Data/Storage",           "UserSettings.swift"),
    ("Storage",                "Data/Storage",           "SwiftDataManager.swift"),
    # Data/Repository
    ("Repository",             "Data/Repository",        "GameRepository.swift"),
    ("Repository",             "Data/Repository",        "AchievementRepository.swift"),
    # Utilities
    ("Utilities",              "Utilities",              "Constants.swift"),
    ("Extensions",             "Utilities/Extensions",   "View+Extensions.swift"),
    ("Extensions",             "Utilities/Extensions",   "TimeInterval+Extensions.swift"),
]

RESOURCE_FILES = [
    ("Resources",  "Resources/Assets.xcassets"),
    ("Resources",  "Resources/Info.plist"),
    ("Presets",    "Data/Presets/PuzzlePresets.json"),
]

TEST_SOURCE_FILES = [
    ("IroPreTests", "PuzzleValidatorTests.swift"),
    ("IroPreTests", "PuzzleGeneratorTests.swift"),
]

# ── Build file & file reference records ─────────────────────────────────────
# Each: { ref_id, build_id, group, path, filename, last_type }
app_sources = []
for (grp, path, fname) in SOURCE_FILES:
    app_sources.append({
        "ref_id":   new_id(),
        "build_id": new_id(),
        "group":    grp,
        "path":     path,
        "filename": fname,
        "filetype": "sourcecode.swift",
    })

app_resources = []
for (grp, path) in RESOURCE_FILES:
    fname = os.path.basename(path)
    ext = fname.rsplit(".", 1)[-1] if "." in fname else ""
    if ext == "xcassets":
        ft = "folder.assetcatalog"
    elif ext == "plist":
        ft = "text.plist.xml"
    elif ext == "json":
        ft = "text.json"
    else:
        ft = "file"
    app_resources.append({
        "ref_id":   new_id(),
        "build_id": new_id(),
        "group":    grp,
        "path":     path,
        "filename": fname,
        "filetype": ft,
    })

test_sources = []
for (grp, fname) in TEST_SOURCE_FILES:
    test_sources.append({
        "ref_id":   new_id(),
        "build_id": new_id(),
        "group":    grp,
        "path":     f"IroPreTests",
        "filename": fname,
        "filetype": "sourcecode.swift",
    })

# ── Group hierarchy ──────────────────────────────────────────────────────────
# Top-level groups inside main group
IROPREDIR_GROUP_ID   = new_id()
TESTDIR_GROUP_ID     = new_id()

# Sub-groups
GROUP_IDS = {}
all_groups = set(f["group"] for f in app_sources + app_resources + test_sources)
for g in all_groups:
    GROUP_IDS[g] = new_id()

# Folder groups for directory structure
CORE_GROUP_ID       = new_id()
FEATURES_GROUP_ID   = new_id()
DATA_GROUP_ID       = new_id()
RESOURCES_GROUP_ID  = new_id()

# ── Helper ───────────────────────────────────────────────────────────────────
def pbx_file_ref(item, base="IroPre"):
    path = f"{base}/{item['path']}/{item['filename']}"
    return (
        f"\t\t{item['ref_id']} = {{"
        f"isa = PBXFileReference; "
        f"lastKnownFileType = {item['filetype']}; "
        f"name = {item['filename']}; "
        f"path = {path}; "
        f"sourceTree = \"<group>\"; }};"
    )

def pbx_build_file(item, attrs=""):
    a = f" settings = {{{attrs}}};" if attrs else ""
    return (
        f"\t\t{item['build_id']} = {{"
        f"isa = PBXBuildFile; "
        f"fileRef = {item['ref_id']}; "
        f"{a}}};"
    )

# ── Assemble sections ────────────────────────────────────────────────────────
lines = []

lines.append("// !$*UTF8*$!")
lines.append("{")
lines.append("\tarchiveVersion = 1;")
lines.append("\tclasses = {")
lines.append("\t};")
lines.append("\tobjectVersion = 77;")
lines.append("\tobjects = {")
lines.append("")

# PBXBuildFile
lines.append("/* Begin PBXBuildFile section */")
for f in app_sources:
    lines.append(pbx_build_file(f))
for f in app_resources:
    lines.append(pbx_build_file(f))
for f in test_sources:
    lines.append(pbx_build_file(f))
# App product in test
TEST_HOST_BUILD_ID = new_id()
lines.append(f"\t\t{TEST_HOST_BUILD_ID} = {{isa = PBXBuildFile; fileRef = {APP_PRODUCT_REF}; }};")
lines.append("/* End PBXBuildFile section */")
lines.append("")

# PBXFileReference
lines.append("/* Begin PBXFileReference section */")
lines.append(f"\t\t{APP_PRODUCT_REF} = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = IroPre.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
lines.append(f"\t\t{TEST_PRODUCT_REF} = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = IroPreTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")
for f in app_sources + app_resources:
    lines.append(pbx_file_ref(f))
for f in test_sources:
    lines.append(pbx_file_ref(f, base="IroPreTests"))
lines.append("/* End PBXFileReference section */")
lines.append("")

# PBXFrameworksBuildPhase
lines.append("/* Begin PBXFrameworksBuildPhase section */")
lines.append(f"\t\t{APP_FRAMEWORKS_PHASE} = {{")
lines.append(f"\t\t\tisa = PBXFrameworksBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = (")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append(f"\t\t{TEST_FRAMEWORKS_PHASE} = {{")
lines.append(f"\t\t\tisa = PBXFrameworksBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = (")
lines.append(f"\t\t\t\t{TEST_HOST_BUILD_ID} /* IroPre.app in Frameworks */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append("/* End PBXFrameworksBuildPhase section */")
lines.append("")

# PBXGroup — collect refs per group
def refs_in_group(gname, items):
    return [f for f in items if f["group"] == gname]

lines.append("/* Begin PBXGroup section */")

# Main group
lines.append(f"\t\t{MAIN_GROUP_ID} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
lines.append(f"\t\t\t\t{IROPREDIR_GROUP_ID} /* IroPre */,")
lines.append(f"\t\t\t\t{TESTDIR_GROUP_ID} /* IroPreTests */,")
lines.append(f"\t\t\t\t{PRODUCTS_GROUP_ID} /* Products */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

# Products
lines.append(f"\t\t{PRODUCTS_GROUP_ID} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
lines.append(f"\t\t\t\t{APP_PRODUCT_REF} /* IroPre.app */,")
lines.append(f"\t\t\t\t{TEST_PRODUCT_REF} /* IroPreTests.xctest */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = Products;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

# IroPre dir group
# Sub-folder group IDs
SUBGROUP = {
    "App":          GROUP_IDS.get("App",        new_id()),
    "Core":         CORE_GROUP_ID,
    "Models":       GROUP_IDS.get("Models",     new_id()),
    "Engine":       GROUP_IDS.get("Engine",     new_id()),
    "Theme":        GROUP_IDS.get("Theme",      new_id()),
    "Features":     FEATURES_GROUP_ID,
    "Home":         GROUP_IDS.get("Home",       new_id()),
    "Game":         GROUP_IDS.get("Game",       new_id()),
    "LevelSelect":  GROUP_IDS.get("LevelSelect",new_id()),
    "Tutorial":     GROUP_IDS.get("Tutorial",   new_id()),
    "Achievements": GROUP_IDS.get("Achievements",new_id()),
    "Settings":     GROUP_IDS.get("Settings",   new_id()),
    "Data":         DATA_GROUP_ID,
    "Storage":      GROUP_IDS.get("Storage",    new_id()),
    "Repository":   GROUP_IDS.get("Repository", new_id()),
    "Presets":      GROUP_IDS.get("Presets",    new_id()),
    "Resources":    GROUP_IDS.get("Resources",  new_id()),
    "Utilities":    GROUP_IDS.get("Utilities",  new_id()),
    "Extensions":   GROUP_IDS.get("Extensions", new_id()),
}

lines.append(f"\t\t{IROPREDIR_GROUP_ID} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
lines.append(f"\t\t\t\t{SUBGROUP['App']} /* App */,")
lines.append(f"\t\t\t\t{SUBGROUP['Core']} /* Core */,")
lines.append(f"\t\t\t\t{SUBGROUP['Features']} /* Features */,")
lines.append(f"\t\t\t\t{SUBGROUP['Data']} /* Data */,")
lines.append(f"\t\t\t\t{SUBGROUP['Resources']} /* Resources */,")
lines.append(f"\t\t\t\t{SUBGROUP['Utilities']} /* Utilities */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = IroPre;")
lines.append(f"\t\t\tpath = IroPre;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

def make_leaf_group(gid, name, path, items):
    out = []
    out.append(f"\t\t{gid} = {{")
    out.append(f"\t\t\tisa = PBXGroup;")
    out.append(f"\t\t\tchildren = (")
    for f in items:
        out.append(f"\t\t\t\t{f['ref_id']} /* {f['filename']} */,")
    out.append(f"\t\t\t);")
    out.append(f"\t\t\tname = {name};")
    if path:
        out.append(f"\t\t\tpath = {path};")
    out.append(f"\t\t\tsourceTree = \"<group>\";")
    out.append(f"\t\t}};")
    return out

# App group
lines += make_leaf_group(SUBGROUP['App'], "App", "App",
    refs_in_group("App", app_sources))

# Core
lines.append(f"\t\t{SUBGROUP['Core']} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
lines.append(f"\t\t\t\t{SUBGROUP['Models']} /* Models */,")
lines.append(f"\t\t\t\t{SUBGROUP['Engine']} /* Engine */,")
lines.append(f"\t\t\t\t{SUBGROUP['Theme']} /* Theme */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = Core;")
lines.append(f"\t\t\tpath = Core;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

lines += make_leaf_group(SUBGROUP['Models'], "Models", "Models",
    refs_in_group("Models", app_sources))
lines += make_leaf_group(SUBGROUP['Engine'], "Engine", "Engine",
    refs_in_group("Engine", app_sources))
lines += make_leaf_group(SUBGROUP['Theme'],  "Theme",  "Theme",
    refs_in_group("Theme", app_sources))

# Features
lines.append(f"\t\t{SUBGROUP['Features']} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
for sub in ["Home","Game","LevelSelect","Tutorial","Achievements","Settings"]:
    lines.append(f"\t\t\t\t{SUBGROUP[sub]} /* {sub} */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = Features;")
lines.append(f"\t\t\tpath = Features;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

for sub in ["Home","Game","LevelSelect","Tutorial","Achievements","Settings"]:
    lines += make_leaf_group(SUBGROUP[sub], sub, sub,
        refs_in_group(sub, app_sources))

# Data
lines.append(f"\t\t{SUBGROUP['Data']} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
lines.append(f"\t\t\t\t{SUBGROUP['Storage']} /* Storage */,")
lines.append(f"\t\t\t\t{SUBGROUP['Repository']} /* Repository */,")
lines.append(f"\t\t\t\t{SUBGROUP['Presets']} /* Presets */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = Data;")
lines.append(f"\t\t\tpath = Data;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

lines += make_leaf_group(SUBGROUP['Storage'],    "Storage",    "Storage",
    refs_in_group("Storage", app_sources))
lines += make_leaf_group(SUBGROUP['Repository'], "Repository", "Repository",
    refs_in_group("Repository", app_sources))
lines += make_leaf_group(SUBGROUP['Presets'],    "Presets",    "Presets",
    refs_in_group("Presets", app_resources))

# Resources
lines += make_leaf_group(SUBGROUP['Resources'], "Resources", "Resources",
    refs_in_group("Resources", app_resources))

# Utilities
lines.append(f"\t\t{SUBGROUP['Utilities']} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
for f in refs_in_group("Utilities", app_sources):
    lines.append(f"\t\t\t\t{f['ref_id']} /* {f['filename']} */,")
lines.append(f"\t\t\t\t{SUBGROUP['Extensions']} /* Extensions */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = Utilities;")
lines.append(f"\t\t\tpath = Utilities;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

lines += make_leaf_group(SUBGROUP['Extensions'], "Extensions", "Extensions",
    refs_in_group("Extensions", app_sources))

# Test group
lines.append(f"\t\t{TESTDIR_GROUP_ID} = {{")
lines.append(f"\t\t\tisa = PBXGroup;")
lines.append(f"\t\t\tchildren = (")
for f in test_sources:
    lines.append(f"\t\t\t\t{f['ref_id']} /* {f['filename']} */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = IroPreTests;")
lines.append(f"\t\t\tpath = IroPreTests;")
lines.append(f"\t\t\tsourceTree = \"<group>\";")
lines.append(f"\t\t}};")

lines.append("/* End PBXGroup section */")
lines.append("")

# PBXNativeTarget
lines.append("/* Begin PBXNativeTarget section */")
lines.append(f"\t\t{APP_TARGET_ID} = {{")
lines.append(f"\t\t\tisa = PBXNativeTarget;")
lines.append(f"\t\t\tbuildConfigurationList = {APP_CONFIG_LIST_ID};")
lines.append(f"\t\t\tbuildPhases = (")
lines.append(f"\t\t\t\t{APP_SOURCES_PHASE} /* Sources */,")
lines.append(f"\t\t\t\t{APP_FRAMEWORKS_PHASE} /* Frameworks */,")
lines.append(f"\t\t\t\t{APP_RESOURCES_PHASE} /* Resources */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tbuildRules = (")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tdependencies = (")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = IroPre;")
lines.append(f"\t\t\tpackageProductDependencies = (")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tproductName = IroPre;")
lines.append(f"\t\t\tproductReference = {APP_PRODUCT_REF};")
lines.append(f"\t\t\tproductType = \"com.apple.product-type.application\";")
lines.append(f"\t\t}};")

TEST_DEPEND_ID = new_id()
TEST_PROXY_ID  = new_id()
lines.append(f"\t\t{TEST_TARGET_ID} = {{")
lines.append(f"\t\t\tisa = PBXNativeTarget;")
lines.append(f"\t\t\tbuildConfigurationList = {TEST_CONFIG_LIST_ID};")
lines.append(f"\t\t\tbuildPhases = (")
lines.append(f"\t\t\t\t{TEST_SOURCES_PHASE} /* Sources */,")
lines.append(f"\t\t\t\t{TEST_FRAMEWORKS_PHASE} /* Frameworks */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tbuildRules = (")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tdependencies = (")
lines.append(f"\t\t\t\t{TEST_DEPEND_ID} /* PBXTargetDependency */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tname = IroPreTests;")
lines.append(f"\t\t\tproductName = IroPreTests;")
lines.append(f"\t\t\tproductReference = {TEST_PRODUCT_REF};")
lines.append(f"\t\t\tproductType = \"com.apple.product-type.bundle.unit-test\";")
lines.append(f"\t\t}};")
lines.append("/* End PBXNativeTarget section */")
lines.append("")

# PBXProject
lines.append("/* Begin PBXProject section */")
lines.append(f"\t\t{PROJECT_ID} = {{")
lines.append(f"\t\t\tisa = PBXProject;")
lines.append(f"\t\t\tattributes = {{")
lines.append(f"\t\t\t\tBuildIndependentTargetsInParallel = 1;")
lines.append(f"\t\t\t\tLastSwiftUpdateCheck = 1600;")
lines.append(f"\t\t\t\tLastUpgradeCheck = 1600;")
lines.append(f"\t\t\t\tTargetAttributes = {{")
lines.append(f"\t\t\t\t\t{APP_TARGET_ID} = {{")
lines.append(f"\t\t\t\t\t\tCreatedOnToolsVersion = 16.0;")
lines.append(f"\t\t\t\t\t}};")
lines.append(f"\t\t\t\t\t{TEST_TARGET_ID} = {{")
lines.append(f"\t\t\t\t\t\tCreatedOnToolsVersion = 16.0;")
lines.append(f"\t\t\t\t\t\tTestTargetID = {APP_TARGET_ID};")
lines.append(f"\t\t\t\t\t}};")
lines.append(f"\t\t\t\t}};")
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tbuildConfigurationList = {PROJ_CONFIG_LIST_ID};")
lines.append(f"\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
lines.append(f"\t\t\tdevelopmentRegion = ja;")
lines.append(f"\t\t\thasScannedForEncodings = 0;")
lines.append(f"\t\t\tknownRegions = (")
lines.append(f"\t\t\t\ten,")
lines.append(f"\t\t\t\tja,")
lines.append(f"\t\t\t\tBase,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tmainGroup = {MAIN_GROUP_ID};")
lines.append(f"\t\t\tproductRefGroup = {PRODUCTS_GROUP_ID};")
lines.append(f"\t\t\tprojectDirPath = \"\";")
lines.append(f"\t\t\tprojectRoot = \"\";")
lines.append(f"\t\t\ttargets = (")
lines.append(f"\t\t\t\t{APP_TARGET_ID} /* IroPre */,")
lines.append(f"\t\t\t\t{TEST_TARGET_ID} /* IroPreTests */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t}};")
lines.append("/* End PBXProject section */")
lines.append("")

# PBXResourcesBuildPhase
lines.append("/* Begin PBXResourcesBuildPhase section */")
lines.append(f"\t\t{APP_RESOURCES_PHASE} = {{")
lines.append(f"\t\t\tisa = PBXResourcesBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = (")
for f in app_resources:
    if f["filename"] != "Info.plist":
        lines.append(f"\t\t\t\t{f['build_id']} /* {f['filename']} in Resources */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append("/* End PBXResourcesBuildPhase section */")
lines.append("")

# PBXSourcesBuildPhase
lines.append("/* Begin PBXSourcesBuildPhase section */")
lines.append(f"\t\t{APP_SOURCES_PHASE} = {{")
lines.append(f"\t\t\tisa = PBXSourcesBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = (")
for f in app_sources:
    lines.append(f"\t\t\t\t{f['build_id']} /* {f['filename']} in Sources */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append(f"\t\t{TEST_SOURCES_PHASE} = {{")
lines.append(f"\t\t\tisa = PBXSourcesBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = (")
for f in test_sources:
    lines.append(f"\t\t\t\t{f['build_id']} /* {f['filename']} in Sources */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append("/* End PBXSourcesBuildPhase section */")
lines.append("")

# PBXTargetDependency
lines.append("/* Begin PBXTargetDependency section */")
lines.append(f"\t\t{TEST_DEPEND_ID} = {{")
lines.append(f"\t\t\tisa = PBXTargetDependency;")
lines.append(f"\t\t\ttarget = {APP_TARGET_ID};")
lines.append(f"\t\t\ttargetProxy = {TEST_PROXY_ID};")
lines.append(f"\t\t}};")
lines.append("/* End PBXTargetDependency section */")
lines.append("")

# PBXContainerItemProxy
lines.append("/* Begin PBXContainerItemProxy section */")
lines.append(f"\t\t{TEST_PROXY_ID} = {{")
lines.append(f"\t\t\tisa = PBXContainerItemProxy;")
lines.append(f"\t\t\tcontainerPortal = {PROJECT_ID};")
lines.append(f"\t\t\tproxyType = 1;")
lines.append(f"\t\t\tremoteGlobalIDString = {APP_TARGET_ID};")
lines.append(f"\t\t\tremoteInfo = IroPre;")
lines.append(f"\t\t}};")
lines.append("/* End PBXContainerItemProxy section */")
lines.append("")

# XCBuildConfiguration
COMMON_APP = """\
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tASSET_CATALOG_COMPILER_OPTIMIZATION = space;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_CYCLE = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (\"DEBUG=1\", "$(inherited)");
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";
\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;
\t\t\t\tSWIFT_VERSION = 6.0;"""

COMMON_APP_RELEASE = """\
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tASSET_CATALOG_COMPILER_OPTIMIZATION = space;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tVALIDATE_PRODUCT = YES;"""

lines.append("/* Begin XCBuildConfiguration section */")

# Project Debug
lines.append(f"\t\t{PROJ_DEBUG_CONFIG_ID} = {{")
lines.append(f"\t\t\tisa = XCBuildConfiguration;")
lines.append(f"\t\t\tbuildSettings = {{")
lines.append(COMMON_APP)
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tname = Debug;")
lines.append(f"\t\t}};")

# Project Release
lines.append(f"\t\t{PROJ_RELEASE_CONFIG_ID} = {{")
lines.append(f"\t\t\tisa = XCBuildConfiguration;")
lines.append(f"\t\t\tbuildSettings = {{")
lines.append(COMMON_APP_RELEASE)
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tname = Release;")
lines.append(f"\t\t}};")

# App Debug
lines.append(f"\t\t{APP_DEBUG_CONFIG_ID} = {{")
lines.append(f"\t\t\tisa = XCBuildConfiguration;")
lines.append(f"\t\t\tbuildSettings = {{")
lines.append(f"\t\t\t\tASSTECATALOG_COMPILER_APPICON_NAME = AppIcon;")
lines.append(f"\t\t\t\tCURRENT_PROJECT_VERSION = 1;")
lines.append(f"\t\t\t\tENABLE_PREVIEWS = YES;")
lines.append(f"\t\t\t\tGENERATE_INFOPLIST_FILE = NO;")
lines.append(f"\t\t\t\tINFOPLIST_FILE = IroPre/Resources/Info.plist;")
lines.append(f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;")
lines.append(f"\t\t\t\tMARKETING_VERSION = 1.0.0;")
lines.append(f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.iropre;")
lines.append(f"\t\t\t\tPRODUCT_NAME = IroPre;")
lines.append(f"\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPAD = NO;")
lines.append(f"\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;")
lines.append(f"\t\t\t\tSWIFT_VERSION = 6.0;")
lines.append(f"\t\t\t\tTARGETED_DEVICE_FAMILY = 1;")
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tname = Debug;")
lines.append(f"\t\t}};")

# App Release
lines.append(f"\t\t{APP_RELEASE_CONFIG_ID} = {{")
lines.append(f"\t\t\tisa = XCBuildConfiguration;")
lines.append(f"\t\t\tbuildSettings = {{")
lines.append(f"\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;")
lines.append(f"\t\t\t\tCURRENT_PROJECT_VERSION = 1;")
lines.append(f"\t\t\t\tENABLE_PREVIEWS = YES;")
lines.append(f"\t\t\t\tGENERATE_INFOPLIST_FILE = NO;")
lines.append(f"\t\t\t\tINFOPLIST_FILE = IroPre/Resources/Info.plist;")
lines.append(f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;")
lines.append(f"\t\t\t\tMARKETING_VERSION = 1.0.0;")
lines.append(f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.iropre;")
lines.append(f"\t\t\t\tPRODUCT_NAME = IroPre;")
lines.append(f"\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPAD = NO;")
lines.append(f"\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;")
lines.append(f"\t\t\t\tSWIFT_VERSION = 6.0;")
lines.append(f"\t\t\t\tTARGETED_DEVICE_FAMILY = 1;")
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tname = Release;")
lines.append(f"\t\t}};")

# Test Debug
lines.append(f"\t\t{TEST_DEBUG_CONFIG_ID} = {{")
lines.append(f"\t\t\tisa = XCBuildConfiguration;")
lines.append(f"\t\t\tbuildSettings = {{")
lines.append(f"\t\t\t\tBUNDLE_LOADER = \"$(TEST_HOST)\";")
lines.append(f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;")
lines.append(f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.iropre.tests;")
lines.append(f"\t\t\t\tPRODUCT_NAME = IroPreTests;")
lines.append(f"\t\t\t\tSWIFT_VERSION = 6.0;")
lines.append(f"\t\t\t\tTARGETED_DEVICE_FAMILY = 1;")
lines.append(f"\t\t\t\tTEST_HOST = \"$(BUILT_PRODUCTS_DIR)/IroPre.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/IroPre\";")
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tname = Debug;")
lines.append(f"\t\t}};")

# Test Release
lines.append(f"\t\t{TEST_RELEASE_CONFIG_ID} = {{")
lines.append(f"\t\t\tisa = XCBuildConfiguration;")
lines.append(f"\t\t\tbuildSettings = {{")
lines.append(f"\t\t\t\tBUNDLE_LOADER = \"$(TEST_HOST)\";")
lines.append(f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;")
lines.append(f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.iropre.tests;")
lines.append(f"\t\t\t\tPRODUCT_NAME = IroPreTests;")
lines.append(f"\t\t\t\tSWIFT_VERSION = 6.0;")
lines.append(f"\t\t\t\tTARGETED_DEVICE_FAMILY = 1;")
lines.append(f"\t\t\t\tTEST_HOST = \"$(BUILT_PRODUCTS_DIR)/IroPre.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/IroPre\";")
lines.append(f"\t\t\t}};")
lines.append(f"\t\t\tname = Release;")
lines.append(f"\t\t}};")

lines.append("/* End XCBuildConfiguration section */")
lines.append("")

# XCConfigurationList
lines.append("/* Begin XCConfigurationList section */")
lines.append(f"\t\t{PROJ_CONFIG_LIST_ID} = {{")
lines.append(f"\t\t\tisa = XCConfigurationList;")
lines.append(f"\t\t\tbuildConfigurations = (")
lines.append(f"\t\t\t\t{PROJ_DEBUG_CONFIG_ID} /* Debug */,")
lines.append(f"\t\t\t\t{PROJ_RELEASE_CONFIG_ID} /* Release */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tdefaultConfigurationIsVisible = 0;")
lines.append(f"\t\t\tdefaultConfigurationName = Release;")
lines.append(f"\t\t}};")
lines.append(f"\t\t{APP_CONFIG_LIST_ID} = {{")
lines.append(f"\t\t\tisa = XCConfigurationList;")
lines.append(f"\t\t\tbuildConfigurations = (")
lines.append(f"\t\t\t\t{APP_DEBUG_CONFIG_ID} /* Debug */,")
lines.append(f"\t\t\t\t{APP_RELEASE_CONFIG_ID} /* Release */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tdefaultConfigurationIsVisible = 0;")
lines.append(f"\t\t\tdefaultConfigurationName = Release;")
lines.append(f"\t\t}};")
lines.append(f"\t\t{TEST_CONFIG_LIST_ID} = {{")
lines.append(f"\t\t\tisa = XCConfigurationList;")
lines.append(f"\t\t\tbuildConfigurations = (")
lines.append(f"\t\t\t\t{TEST_DEBUG_CONFIG_ID} /* Debug */,")
lines.append(f"\t\t\t\t{TEST_RELEASE_CONFIG_ID} /* Release */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\tdefaultConfigurationIsVisible = 0;")
lines.append(f"\t\t\tdefaultConfigurationName = Release;")
lines.append(f"\t\t}};")
lines.append("/* End XCConfigurationList section */")
lines.append("")

lines.append("\t};")
lines.append(f"\trootObject = {PROJECT_ID};")
lines.append("}")

# ── Write output ─────────────────────────────────────────────────────────────
os.makedirs("IroPre.xcodeproj", exist_ok=True)
output_path = "IroPre.xcodeproj/project.pbxproj"
with open(output_path, "w") as f:
    f.write("\n".join(lines))

print(f"Generated {output_path} ({len(lines)} lines)")
