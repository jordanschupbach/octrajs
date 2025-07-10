
const fs = require('fs');
const { execSync } = require('child_process');

// Path to the binding.gyp file
const gypFilePath = 'binding.gyp';

// Remove binding.gyp if it exists
if (fs.existsSync(gypFilePath)) {
    fs.unlinkSync(gypFilePath);
    console.log('Removed existing binding.gyp file.');
}

// Get the include directory for libxml2 (NOTE: assumes pkg-config is installed (for nixos).. maybe should have list of assumed locs for all os's or detect?)
const includeDir = execSync('pkg-config --cflags-only-I libxml-2.0 | sed "s/-I//g"').toString().trim();
// const libDir = execSync('pkg-config --libs-only-L libxml-2.0 | sed "s/-L//g"').toString().trim();

// Prepare the content for node.gyp
const gypContent = `
{
  'targets': [
    {
      'target_name': 'octrajs',
      'sources': [ 'src/octra/cxx/circle.cpp', 'src/octra/cxx/dynarray.cpp',  'src/octra/octra_wrap.cxx' ],
      'include_dirs': ["src", "<!@(node -p \\\"require('node-addon-api').include\\\")",
          # "<!@(pkg-config --cflags-only-I libxml-2.0 | sed 's/-I//g' | echo)",
          '${includeDir}'
          # "/nix/store/cisb0723v3pgp74f2lj07z5d6w3j77sl-libxml2-2.13.8-dev/include/libxml2"
      ],
      'dependencies': ["<!(node -p \\\"require('node-addon-api').gyp\\\")"],
      'cflags': ['-std=c++23'],
      'cflags!': [ '-fno-exceptions', '-fno-rtti'], # ,
      'cflags_cc': ['-std=c++23'],
      'cflags_cc!': [ '-fno-exceptions', '-fno-rtti'], # '-fno-rtti'
      # 'GCC_ENABLE_CPP_RTTI': 'NO',              # -fno-rtti   ???
      'xcode_settings': {
        'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
        'CLANG_CXX_LIBRARY': 'libc++',
        'MACOSX_DEPLOYMENT_TARGET': '10.14',
        'GCC_ENABLE_CPP_RTTI': 'YES'
      },
      'libraries' : [ '-lxml2' ], # '-lblas', '-llapack', '-llapacke', '-lcblas'
      'library_dirs' : [ '/usr/lib' ],
      'msvs_settings': {
        'VCCLCompilerTool': { 'ExceptionHandling': 1 },
      }
    }
  ]
}`;

// Write to node.gyp
fs.writeFileSync('binding.gyp', gypContent);
console.log('binding.gyp file generated successfully.');
