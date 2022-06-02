using Plots

function plotting()

    x1 = ["DataFlowTasks"] ; x2 = ["Dagger"] 
    y1 = [0.005] ; y2 = [0.1]
    bar(
        x1, y1,
        title = "Overhead for creating 400 (independent) tasks",
        ylabel = "Overhead (s)",
        legend=:none,
        color=:purple
    )
    bar!(
        x2, y2
    )

end
plotting()

savefig("./fig/task_overhead.png")