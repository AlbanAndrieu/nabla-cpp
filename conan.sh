#!/bin/bash
#set -xv
#set -eu

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

echo -e "${cyan} ${double_arrow} Conan install ${NC}"

#conan profile new test --detect
conan profile list
echo "conan profile update settings.compiler.libcxx=libstdc++11 default"
#ls -lrta $HOME/.conan/profiles
conan profile show default

#See https://conan.io/
#See https://bintray.com/bincrafters/public-conan

if [ -n "${ENABLE_CLANG}" ]; then

    if [ "$(uname -s)" == "Linux" ]; then
    
        case $(uname -m) in
        x86_64)	    
            echo -e "${green} ENABLE_CLANG is undefined, using CONAN ${happy_smiley} ${NC}"            

            #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
            ##conan install ../microsoft/ -s os="Linux" -s compiler="clang"
            ##conan install ../microsoft/ boost/1.67.0@conan/stable -s compiler.version=6.4

            ;;
        i*86)
            ;;
        *)
            # leave ARCH as-is
            ;;
        esac
        
    fi
    
fi

if [ "$(uname -s)" == "Linux" ]; then

    case $(uname -m) in
    x86_64)	    
        echo -e "${green} Using CONAN ${happy_smiley} ${NC}"            
        
        conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan
        conan user -r nabla albanandrieu
          
        #conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
        #conan user -p 24809e026911e16eaa40b63acbf05eaec557d963 -r nabla albanandrieu
        
        #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
        ##conan install ../microsoft/ boost/1.67.0@conan/stable -s compiler.version=6.4
        #conan install boost_system/1.66.0@bincrafters/stable --build boost_system
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system ${NC}"
        conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system
        #conan info${WORKING_DIR}/sample/microsoft/ --graph=file.html
        
        conan profile list  
        conan profile update settings.compiler.libcxx=libstdc++11 default  
            
        ;;
    i*86)
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac
    
fi

exit 0
