# import bokeh modules
from bokeh.io import output_notebook, output_file, show, export_png
from bokeh.plotting import figure
from bokeh.models import ColumnDataSource, Range1d, DataRange1d, Plot, CategoricalColorMapper, LabelSet, BoxAnnotation
from bokeh.models.tools import HoverTool
from bokeh.models.glyphs import Circle, Text
from bokeh.palettes import Spectral5
from bokeh.transform import factor_cmap
from bokeh.models.annotations import Label

import pandas as pd
import numpy as np

def plot_LogsOvertime(df, col1, col2,title,x_label, y_label, tooltips = [('count', '@count')]):
    """return interactive line plot using bokeh"""

    grouped = pd.DataFrame(df.groupby([col1])[col2].sum())
    grouped.reset_index(inplace=True)

# set amounts by billion dollars
    #grouped[col2]=grouped[col2]/col_transform
    source = ColumnDataSource(grouped)

# initialize the figure
    p = figure(title = title,plot_width = 1000,
               plot_height = 450, x_axis_type='datetime')

    # create the plot
    p.line(x=col1,
           y=col2,
           line_width=3,
           source=source)

    # set formating parameters
    p.xgrid.grid_line_color = None
    p.ygrid.grid_line_color = None
    p.title.text_font_size = "16pt"
    p.title.text_color = 'MidnightBlue'
    p.xaxis.axis_label_text_font_size = '15pt'
    p.yaxis.axis_label_text_font_size = '15pt'
    p.yaxis.axis_label = y_label
    p.xaxis.axis_label = x_label
    p.xaxis.major_label_text_font_size = '12pt'

    # add interactive hover tool that shows the amount awarded
    hover = HoverTool()
    #hover.tooltips = [('count', '@count')]
    hover.tooltips = tooltips


    hover.mode = 'vline'
    p.add_tools(hover)

    #display plot
    show(p)
