# Concepts

This framework uses three main concepts:

- **Route** - an identifiable value that represents a destination in your app 
- **Transition** - a visual transition to be applied on a view 
- **Coordinator** - an object that maps **routes** to **transitions** and applies it on the current view hierarchy 

# Getting Started 

### Definite a set of destinations

A destination could be a screen, a modal or even a dismiss action. Destinations are typically represented via `enum`s.

```swift
enum AppDestination {
    case first
    case second
    case third
}
```

### Define a coordinator

There are three steps to defining a coordinator:

1. You must subclass either `UIViewControllerCoordinator` or `UIViewControllerCoordinator`
2. You must parametrize your subclass with a **route**.
3. You must override and implement the function `transition(for:)`, which is responsible for mapping a **route** to a **transition**.

```swift
class AppCoordinator: UIWindowCoordinator<AppDestination> {
    override func transition(for route: AppDestination) -> ViewTransition {
        switch route {
            case .first:
                return .present(Text("First"))
            case .second:
                return .push(Text("Second"))
            case .third:
                return .set(Text("third"))
        }
    }
}
```

### Integrate your coordinator

Coordinators can be integrated in a fashion similar to `@EnvironmentObject`. For this example, we'll create an instance of the `AppCoordinator` defined in the previous section, and pass it to a `ContentView` via the `View/coordinator(_:)` function.

`ContentView` uses the coordinator via a special property wrapper, `@Coordinator`, which gives access to the nearest available coordinator for a given route type at runtime (in this case, `AppCoordinator`).

```swift
@main
struct App: SwiftUI.App {
    @StateObject var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .coordinator(coordinator)
            }
        }
    }
}

struct ContentView: View {
    @Coordinator(for: AppDestination.self) var coordinator
    
    var body: some View {
        VStack {
            Button("First") {
                coordinator.trigger(.first)
            }
            
            Button("Second") {
                coordinator.trigger(.second)
            }
            
            Button("Third") {
                coordinator.trigger(.third)
            }
        }
    }
}
```

