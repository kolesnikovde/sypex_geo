module SypexGeo
  class MemoryDatabase < Database
    def setup!
      super

      @db = @file.read(@db_items * @block_len)
      @regions_db = @file.read(@region_size) if @region_size > 0
      @cities_db = @file.read(@city_size) if @city_size > 0
    end

    def search_db(ipn, min, max)
      search_db_chunk(@db, ipn, min, max)
    end

    def read_data(seek, limit, type)
      raw = (type == TYPE_REGION ? @regions_db : @cities_db)[seek, limit]
      Pack.parse(@pack[type], raw)
    end
  end
end
