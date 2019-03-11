public class Git {
    public init() { }
    
    public func status(_ user: User) -> String {
        return try! Shell.message("git config --list", location: user.bookmark.first!.0) + ":"
            + (try! Shell.message("git config --global user.email", location: user.bookmark.first!.0)) + "\n"
            + (try! Shell.message("git status", location: user.bookmark.first!.0)) + "\n"
    }
    
    public func commit(_ user: User) -> String {
//        print("user: \(try! Shell.message("git config user.name", location: user.bookmark.first!.0))")
        return try! Shell.message("git add .", location: user.bookmark.first!.0) + "\n"
            + (try! Shell.message("git commit -m \"meta\"", location: user.bookmark.first!.0)) + "\n"
    }
    
    public func reset(_ user: User) -> String {
        return try! Shell.message("git reset --hard", location: user.bookmark.first!.0) + "\n"
    }
    
    
    public func pull(_ user: User) -> String { return try! Shell.message("git pull", location: user.bookmark.first!.0) + "\n" }
    public func push(_ user: User) -> String { return try! Shell.message("git push", location: user.bookmark.first!.0) + "\n" }
}
