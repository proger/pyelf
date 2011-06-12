#   $SYSREVERSE: propcache.py,v 1.6 2011/02/05 21:14:02 proger Exp $

_missing = object()

class CachingObject(object):
    __slots__ = ('data', '_cache')

    def __init__(self, **kwargs):
        self.data = kwargs
        self._cache = dict()

    def __getattr__(self, name, default=_missing):
        if name == '__dict__':
            return self.data
        return self.data.get(name)

    def __getstate__(self): # for pickle
        return

class cached_property(object):
    """
    cached_property for objects which contain the _cache field
    """
    def __init__(self, func, name=None, doc=None):
        self.__name__ = name or func.__name__
        self.__module__ = func.__module__
        self.__doc__ = doc or func.__doc__
        self.func = func

    def __get__(self, obj, type=None):
        if obj is None:
            return self

        value = obj._cache.get(self.__name__, _missing)

        if value is _missing:
            value = self.func(obj)
            obj._cache[self.__name__] = value
        return value

    def __set__(self, obj, val):
        obj._cache[self.__name__] = _missing
        #obj._cache[self.__name__] = val
