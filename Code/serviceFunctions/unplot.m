%UNPLOT Remove the last line drawn in a plot
children = get(gca, 'children');
delete(children(1));