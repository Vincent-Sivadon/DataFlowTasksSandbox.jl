using Plots

function plotting_testcase1()

    x1 = ["DataFlowTasks"] ; x2 = ["Dagger"] 
    y1 = [6] ; y2 = [103]
    bar(
        x1, y1,
        title = "Overhead for creating 400 (independent) tasks",
        ylabel = "Overhead (ms)",
        legend=:none,
        color=:purple
    )
    bar!(
        x2, y2
    )

end
plotting_testcase1()
savefig("./fig/task_overhead_testcase1.png")

function plotting_testcase2()

    x1 = ["DataFlowTasks"] ; x2 = ["Dagger"] 
    y1 = [7.08] ; y2 = [154]
    bar(
        x1, y1,
        title = "Overhead for creating 400 tasks (with dependance)",
        ylabel = "Overhead (ms)",
        legend=:none,
        color=:purple
    )
    bar!(
        x2, y2
    )
end
plotting_testcase2()
savefig("./fig/task_overhead_testcase2.png")