pod deintegrate
rm -rf Pods Podfile.lock .symlinks ~/Library/Developer/Xcode/DerivedData/*
pod cache clean --all
rm -rf Pods
rm -rf Podfile.lock
rm -rf ~/Library/Caches/CocoaPods
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod repo update
pod install
