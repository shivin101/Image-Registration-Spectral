function result=sample_img(img,subsampleRate)
    result=img(1:subsampleRate:end,1:subsampleRate:end);
end