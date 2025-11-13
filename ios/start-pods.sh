pod deintegrate
rm -rf Pods Podfile.lock .symlinks ~/Library/Developer/Xcode/DerivedData/*
pod cache clean --all
pod repo update
pod install --repo-update
