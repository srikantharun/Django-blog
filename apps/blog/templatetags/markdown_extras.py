from django import template
from django.template.defaultfilters import stringfilter
import markdown as md
from django.utils.safestring import mark_safe

register = template.Library()

@register.filter()
@stringfilter
def markdown(value):
    """Convert markdown text to safe HTML."""
    return mark_safe(md.markdown(value, 
                               extensions=[
                                   'markdown.extensions.fenced_code',
                                   'markdown.extensions.codehilite',
                                   'markdown.extensions.tables',
                                   'markdown.extensions.toc'
                               ]))