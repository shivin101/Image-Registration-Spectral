function resultant_eig = process_eig(vec)
    for i=1:size(vec,2)
        evec=vec(:,i);
        idx1 = find(evec<0);
        idx2 = find(evec>0);
        val1=min(evec(idx1));
        val2=max(evec(idx2));
        evec(idx1)=evec(idx1)./abs(val1);
        evec(idx2)=evec(idx2)./abs(val2);
        resultant_eig(:,i)=evec;
    end
    
end